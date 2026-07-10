package cn.nine.pros.post.biz.service.biz.impl;

import cn.nine.commons.basic.exception.unchecked.BusinessException;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.model.domain.LetterDomain;
import cn.nine.pros.post.biz.model.domain.PenpalRequestDomain;
import cn.nine.pros.post.biz.service.base.ActionService;
import cn.nine.pros.post.biz.service.base.ConfigService;
import cn.nine.pros.post.biz.service.base.FriendshipService;
import cn.nine.pros.post.biz.service.base.LetterService;
import cn.nine.pros.post.biz.service.base.OssDisplayUrlService;
import cn.nine.pros.post.biz.service.base.PenpalRequestService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.biz.service.biz.AppBlacklistService;
import cn.nine.pros.post.biz.service.biz.AppRelationBizService;
import cn.nine.pros.post.biz.service.biz.support.UserAvatarAuditSupport;
import cn.nine.pros.post.client.common.constant.BehaviorActionTypes;
import cn.nine.pros.post.client.common.enums.LetterBizStatus;
import cn.nine.pros.post.client.common.enums.PenpalRequestStatus;
import cn.nine.pros.post.client.common.enums.RelationDisplayState;
import cn.nine.pros.post.client.model.db.UserDTO;
import cn.nine.pros.post.client.model.input.app.CreatePenpalRequestInDto;
import cn.nine.pros.post.client.model.out.AppPublicUserVO;
import cn.nine.pros.post.client.model.out.PenpalRequestResultVO;
import cn.nine.pros.post.client.model.out.PostOfficeRelationMessageVO;
import cn.nine.pros.post.client.model.out.RelationSnapshotVO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Objects;
import java.util.Set;

@Slf4j
@Service
@RequiredArgsConstructor
public class AppRelationBizServiceImpl implements AppRelationBizService {

    private static final String KEY_MIN_EXCHANGE = "penpal.min_exchange_count";
    private static final int DEFAULT_MIN_EXCHANGE = 2;
    private static final int MSG_TYPE_REQUEST = 1;
    private static final int MSG_TYPE_HINT = 2;

    private final FriendshipService friendshipService;
    private final PenpalRequestService penpalRequestService;
    private final LetterService letterService;
    private final UserService userService;
    private final ConfigService configService;
    private final AppBlacklistService appBlacklistService;
    private final ActionService actionService;
    private final OssDisplayUrlService ossDisplayUrlService;
    private final AppMessages appMessages;

    @Override
    public RelationSnapshotVO resolveRelationSnapshot(long viewerUserId, long peerUserId) {
        if (viewerUserId == peerUserId) {
            return RelationSnapshotVO.builder()
                    .peerUserId(peerUserId)
                    .displayState(RelationDisplayState.STRANGER.getCode())
                    .letterCount(0)
                    .canAddPenpal(false)
                    .penpal(false)
                    .build();
        }
        if (friendshipService.areActiveFriends(viewerUserId, peerUserId)) {
            int count = (int) letterService.countExchangeBetween(viewerUserId, peerUserId);
            return RelationSnapshotVO.builder()
                    .peerUserId(peerUserId)
                    .displayState(RelationDisplayState.PENPAL.getCode())
                    .letterCount(count)
                    .canAddPenpal(false)
                    .penpal(true)
                    .build();
        }
        PenpalRequestDomain pending = penpalRequestService.findPendingBetween(viewerUserId, peerUserId);
        if (pending != null) {
            int count = (int) letterService.countExchangeBetween(viewerUserId, peerUserId);
            boolean out = Objects.equals(pending.getRequesterId(), viewerUserId);
            return RelationSnapshotVO.builder()
                    .peerUserId(peerUserId)
                    .displayState(out
                            ? RelationDisplayState.PENDING_OUT.getCode()
                            : RelationDisplayState.PENDING_IN.getCode())
                    .letterCount(count)
                    .canAddPenpal(false)
                    .pendingRequestId(pending.getId())
                    .penpal(false)
                    .build();
        }
        return buildNonPenpalSnapshot(viewerUserId, peerUserId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public PenpalRequestResultVO createPenpalRequest(long actorUserId, CreatePenpalRequestInDto body) {
        if (body == null || body.getPeerUserId() == null) {
            throw new BusinessException(appMessages.get("app.error.penpal.peerRequired"));
        }
        return doCreatePenpalRequest(actorUserId, body.getPeerUserId(), body.getSourceLetterId());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public PenpalRequestResultVO createPenpalRequestFromLetter(long actorUserId, long letterId) {
        LetterDomain letter = letterService.getById(letterId);
        if (letter == null || letter.isDelFlag()) {
            throw new BusinessException(appMessages.get("app.error.letter.notFound"));
        }
        long peer = peerFromLetter(letter, actorUserId);
        if (peer <= 0) {
            throw new BusinessException(appMessages.get("app.error.penpal.invalidLetter"));
        }
        return doCreatePenpalRequest(actorUserId, peer, letterId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public PenpalRequestResultVO acceptPenpalRequest(long actorUserId, long requestId) {
        PenpalRequestDomain req = loadPendingForTarget(actorUserId, requestId);
        friendshipService.createPenpalFromRequest(
                actorUserId, req.getRequesterId(), req.getTargetId(), req.getSourceLetterId());
        penpalRequestService.markAccepted(requestId, actorUserId);
        actionService.recordEvent(
                actorUserId,
                BehaviorActionTypes.ACCEPT_PENPAL,
                BehaviorActionTypes.TARGET_USER,
                req.getRequesterId(),
                null);
        log.info("penpal request accepted, actorUserId={}, requestId={}, requesterId={}",
                actorUserId, requestId, req.getRequesterId());
        return toResult(req, PenpalRequestStatus.ACCEPTED);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public PenpalRequestResultVO ignorePenpalRequest(long actorUserId, long requestId) {
        PenpalRequestDomain req = loadPendingForTarget(actorUserId, requestId);
        penpalRequestService.markIgnored(requestId, actorUserId);
        actionService.recordEvent(
                actorUserId,
                BehaviorActionTypes.REJECT_PENPAL,
                BehaviorActionTypes.TARGET_USER,
                req.getRequesterId(),
                null);
        log.info("penpal request ignored, actorUserId={}, requestId={}", actorUserId, requestId);
        return toResult(req, PenpalRequestStatus.IGNORED);
    }

    @Override
    public List<PostOfficeRelationMessageVO> listRelationMessages(long viewerUserId) {
        List<PostOfficeRelationMessageVO> out = new ArrayList<>();
        appendIncomingRequests(viewerUserId, out);
        appendRelationHints(viewerUserId, out);
        return out;
    }

    @Override
    public int countRelationMessages(long viewerUserId) {
        return listRelationMessages(viewerUserId).size();
    }

    private PenpalRequestResultVO doCreatePenpalRequest(long actorUserId, long peerUserId, Long sourceLetterId) {
        if (peerUserId == actorUserId) {
            throw new BusinessException(appMessages.get("app.error.penpal.cannotSelf"));
        }
        if (friendshipService.areActiveFriends(actorUserId, peerUserId)) {
            throw new BusinessException(appMessages.get("app.error.penpal.alreadyPenpal"));
        }
        if (penpalRequestService.existsPendingBetween(actorUserId, peerUserId)) {
            throw new BusinessException(appMessages.get("app.error.penpal.pendingExists"));
        }
        if (appBlacklistService.areMutuallyBlocked(actorUserId, peerUserId)) {
            throw new BusinessException(appMessages.get("app.error.penpal.blocked"));
        }
        RelationSnapshotVO snap = buildNonPenpalSnapshot(actorUserId, peerUserId);
        if (!Boolean.TRUE.equals(snap.getCanAddPenpal())) {
            throw new BusinessException(appMessages.get("app.error.penpal.thresholdNotMet"));
        }
        PenpalRequestDomain row = new PenpalRequestDomain();
        row.setRequesterId(actorUserId);
        row.setTargetId(peerUserId);
        row.setStatus(PenpalRequestStatus.PENDING.getCode());
        row.setSourceLetterId(sourceLetterId);
        row.initAudit(actorUserId);
        penpalRequestService.save(row);
        actionService.recordEvent(
                actorUserId,
                BehaviorActionTypes.ADD_PENPAL_REQUEST,
                BehaviorActionTypes.TARGET_USER,
                peerUserId,
                null);
        log.info("penpal request created, requesterId={}, targetId={}, requestId={}",
                actorUserId, peerUserId, row.getId());
        return PenpalRequestResultVO.builder()
                .requestId(row.getId())
                .peerUserId(peerUserId)
                .status(PenpalRequestStatus.PENDING.getCode())
                .createdAt(row.getCreatedAt())
                .build();
    }

    private RelationSnapshotVO buildNonPenpalSnapshot(long viewerUserId, long peerUserId) {
        int count = (int) letterService.countExchangeBetween(viewerUserId, peerUserId);
        int threshold = configService.getInt(KEY_MIN_EXCHANGE, DEFAULT_MIN_EXCHANGE);
        boolean bidirectional = letterService.hasBidirectionalExchange(viewerUserId, peerUserId);
        boolean canAdd = bidirectional && count >= threshold;
        RelationDisplayState state = RelationDisplayState.STRANGER;
        if (count > 0 && !canAdd) {
            state = RelationDisplayState.CONTACTING;
        }
        if (canAdd) {
            state = RelationDisplayState.CAN_ADD_PENPAL;
        }
        return RelationSnapshotVO.builder()
                .peerUserId(peerUserId)
                .displayState(state.getCode())
                .letterCount(count)
                .canAddPenpal(canAdd)
                .penpal(false)
                .build();
    }

    private void appendIncomingRequests(long viewerUserId, List<PostOfficeRelationMessageVO> out) {
        List<PenpalRequestDomain> rows = penpalRequestService.listIncomingPending(viewerUserId, 50);
        for (PenpalRequestDomain row : rows) {
            if (row.getRequesterId() == null) {
                continue;
            }
            int count = (int) letterService.countExchangeBetween(viewerUserId, row.getRequesterId());
            out.add(PostOfficeRelationMessageVO.builder()
                    .messageType(MSG_TYPE_REQUEST)
                    .requestId(row.getId())
                    .peer(toPublicUser(viewerUserId, row.getRequesterId()))
                    .letterCount(count)
                    .canAddPenpal(false)
                    .build());
        }
    }

    private void appendRelationHints(long viewerUserId, List<PostOfficeRelationMessageVO> out) {
        Set<Long> seen = new HashSet<>();
        for (PenpalRequestDomain row : penpalRequestService.listIncomingPending(viewerUserId, 100)) {
            if (row.getRequesterId() != null) {
                seen.add(row.getRequesterId());
            }
        }
        List<Long> peers = letterService.listExchangePeerIds(viewerUserId, 30);
        for (Long peerId : peers) {
            if (peerId == null || seen.contains(peerId)) {
                continue;
            }
            if (friendshipService.areActiveFriends(viewerUserId, peerId)) {
                continue;
            }
            if (penpalRequestService.existsPendingBetween(viewerUserId, peerId)) {
                continue;
            }
            RelationSnapshotVO snap = buildNonPenpalSnapshot(viewerUserId, peerId);
            if (!Boolean.TRUE.equals(snap.getCanAddPenpal())) {
                continue;
            }
            seen.add(peerId);
            out.add(PostOfficeRelationMessageVO.builder()
                    .messageType(MSG_TYPE_HINT)
                    .peer(toPublicUser(viewerUserId, peerId))
                    .letterCount(snap.getLetterCount())
                    .canAddPenpal(true)
                    .build());
        }
    }

    private PenpalRequestDomain loadPendingForTarget(long actorUserId, long requestId) {
        PenpalRequestDomain req = penpalRequestService.getById(requestId);
        if (req == null || req.isDelFlag()) {
            throw new BusinessException(appMessages.get("app.error.penpal.requestNotFound"));
        }
        if (!Objects.equals(req.getTargetId(), actorUserId)) {
            throw new BusinessException(appMessages.get("app.error.penpal.notTarget"));
        }
        if (!Objects.equals(req.getStatus(), PenpalRequestStatus.PENDING.getCode())) {
            throw new BusinessException(appMessages.get("app.error.penpal.requestClosed"));
        }
        return req;
    }

    private AppPublicUserVO toPublicUser(long viewerUserId, long userId) {
        UserDTO dto = userService.findById(userId);
        if (dto == null) {
            return AppPublicUserVO.builder().id(userId).nickname("?").build();
        }
        String avatar = UserAvatarAuditSupport.publicStoredRef(dto);
        if (StringUtils.hasText(avatar)) {
            avatar = ossDisplayUrlService.signAvatarForViewer(viewerUserId, avatar.trim());
        }
        return AppPublicUserVO.builder()
                .id(dto.getId())
                .nickname(dto.getNickname())
                .gender(dto.getGender())
                .birthYear(dto.getBirthYear())
                .countryCode(dto.getCountryCode())
                .bio(dto.getBio())
                .avatarUrl(avatar)
                .isVip(dto.getIsVip())
                .build();
    }

    private static long peerFromLetter(LetterDomain letter, long actorUserId) {
        if (Objects.equals(letter.getFromUserId(), actorUserId) && letter.getToUserId() != null) {
            return letter.getToUserId();
        }
        if (Objects.equals(letter.getToUserId(), actorUserId) && letter.getFromUserId() != null) {
            return letter.getFromUserId();
        }
        return 0L;
    }

    private static PenpalRequestResultVO toResult(PenpalRequestDomain req, PenpalRequestStatus status) {
        long peer = req.getRequesterId() != null ? req.getRequesterId() : 0L;
        return PenpalRequestResultVO.builder()
                .requestId(req.getId())
                .peerUserId(peer)
                .status(status.getCode())
                .createdAt(req.getCreatedAt())
                .build();
    }
}
