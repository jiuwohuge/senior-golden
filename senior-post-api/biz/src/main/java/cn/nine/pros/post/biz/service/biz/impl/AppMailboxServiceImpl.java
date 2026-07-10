package cn.nine.pros.post.biz.service.biz.impl;

import cn.nine.commons.basic.exception.unchecked.BusinessException;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.model.domain.FriendshipDomain;
import cn.nine.pros.post.biz.model.domain.LetterDomain;
import cn.nine.pros.post.biz.service.biz.AppBlacklistService;
import cn.nine.pros.post.biz.service.biz.AppMailboxService;
import cn.nine.pros.post.biz.service.biz.WritingStyleService;
import cn.nine.pros.post.biz.service.base.FriendshipService;
import cn.nine.pros.post.biz.service.base.LetterService;
import cn.nine.pros.post.biz.service.base.SensitiveWordService;
import cn.nine.pros.post.biz.service.base.OssDisplayUrlService;
import cn.nine.pros.post.biz.service.biz.support.UserAvatarAuditSupport;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.client.common.enums.LetterBizStatus;
import cn.nine.pros.post.client.common.enums.LetterPhysicalType;
import cn.nine.pros.post.client.common.enums.LetterSendMode;
import cn.nine.pros.post.client.model.db.UserDTO;
import cn.nine.pros.post.client.model.input.app.AppSendLetterInDto;
import cn.nine.pros.post.client.model.out.AcceptPostalContactResultVO;
import cn.nine.pros.post.client.model.out.AppPublicUserVO;
import cn.nine.pros.post.client.model.out.LetterSyncResultVO;
import cn.nine.pros.post.client.model.out.MailboxFriendItemVO;
import cn.nine.pros.post.client.model.out.MailboxLetterItemVO;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.concurrent.ThreadLocalRandom;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AppMailboxServiceImpl implements AppMailboxService {

    private static final int USER_STATUS_NORMAL = 1;

    private final LetterService letterService;
    private final FriendshipService friendshipService;
    private final UserService userService;
    private final SensitiveWordService sensitiveWordService;
    private final OssDisplayUrlService ossDisplayUrlService;
    private final AppBlacklistService appBlacklistService;
    private final WritingStyleService writingStyleService;
    private final AppMessages appMessages;

    @Override
    public List<MailboxLetterItemVO> listPostalInbox(Long userId) {
        List<LetterDomain> letters = loadLettersForUser(userId, null, 500);
        List<MailboxLetterItemVO> out = new ArrayList<>();
        for (LetterDomain l : letters) {
            if (!includeInPostalInbox(l, userId)) {
                continue;
            }
            out.add(toItem(l, userId, false));
        }
        return out;
    }

    @Override
    public LetterSyncResultVO sync(Long userId, LocalDateTime since) {
        List<LetterDomain> letters = loadLettersForUser(userId, since, 500);
        List<MailboxLetterItemVO> items = letters.stream()
                .filter(l -> includeInPostalInbox(l, userId))
                .map(l -> toItem(l, userId, false))
                .collect(Collectors.toList());
        return LetterSyncResultVO.builder()
                .letters(items)
                .serverTime(LocalDateTime.now())
                .build();
    }

    @Override
    public List<MailboxLetterItemVO> listArchive(Long userId) {
        return loadLettersForUser(userId, null, 500).stream()
                .map(l -> toItem(l, userId, false))
                .collect(Collectors.toList());
    }

    @Override
    public AcceptPostalContactResultVO acceptPostalContact(Long actorUserId, Long letterId) {
        FriendshipDomain f = friendshipService.ensureActiveFriendship(actorUserId, letterId);
        LetterDomain letter = letterService.getById(letterId);
        long peer = peerUserId(letter, actorUserId);
        return AcceptPostalContactResultVO.builder()
                .friendshipId(f.getId())
                .peerUserId(peer)
                .build();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public MailboxLetterItemVO sendLetter(long fromUserId, AppSendLetterInDto body) {
        Long parentLetterId = body.getParentLetterId();
        long toUserId;
        if (parentLetterId != null) {
            LetterDomain parent = letterService.getById(parentLetterId);
            if (parent == null || parent.isDelFlag()) {
                throw new BusinessException(appMessages.get("app.error.letter.originalMissing"));
            }
            if (!Objects.equals(parent.getToUserId(), fromUserId)) {
                throw new BusinessException(appMessages.get("app.error.letter.replyRecipientOnly"));
            }
            long replyTo = parent.getFromUserId();
            if (body.getToUserId() != null && !body.getToUserId().equals(replyTo)) {
                throw new BusinessException(appMessages.get("app.error.letter.replyPeerMismatch"));
            }
            if (replyTo == fromUserId) {
                throw new BusinessException(appMessages.get("app.error.letter.cannotMailSelf"));
            }
            toUserId = replyTo;
        } else {
            if (body.getToUserId() == null || body.getToUserId().equals(fromUserId)) {
                throw new BusinessException(appMessages.get("app.error.letter.cannotMailSelf"));
            }
            toUserId = body.getToUserId();
        }

        String raw = body.getContent();
        if (!StringUtils.hasText(raw)) {
            throw new BusinessException(appMessages.get("app.error.letter.contentEmpty"));
        }
        String content = raw.trim();
        if (content.length() > 20000) {
            throw new BusinessException(appMessages.get("app.error.letter.contentTooLong"));
        }
        sensitiveWordService.assertPlainTextAllowed(content);
        LetterPhysicalType physicalType = LetterPhysicalType.fromCode(body.getLetterType());
        if (physicalType == null) {
            throw new BusinessException(appMessages.get("app.error.letter.typeInvalid"));
        }

        UserDTO toUser = userService.findById(toUserId);
        if (toUser == null) {
            throw new BusinessException(appMessages.get("app.error.recipient.notFound"));
        }
        if (userStatus(toUser.getStatus()) != USER_STATUS_NORMAL) {
            throw new BusinessException(appMessages.get("app.error.recipient.statusBad"));
        }
        UserDTO sender = userService.findById(fromUserId);
        if (sender == null || userStatus(sender.getStatus()) != USER_STATUS_NORMAL) {
            throw new BusinessException(appMessages.get("app.error.sender.statusBad"));
        }
        if (appBlacklistService.areMutuallyBlocked(fromUserId, toUserId)) {
            throw new BusinessException(appMessages.get("app.error.mail.cannotSendToPeer"));
        }

        boolean vip = Boolean.TRUE.equals(sender.getIsVip());
        LocalDateTime now = LocalDateTime.now();
        LetterDomain letter = new LetterDomain();
        letter.setFromUserId(fromUserId);
        letter.setToUserId(toUserId);
        letter.setContent(content);
        letter.setIsAccelerated(false);
        letter.setParentLetterId(parentLetterId);

        if (physicalType == LetterPhysicalType.STANDARD) {
            letter.setLetterType(LetterPhysicalType.STANDARD.getCode());
            letter.setStatus(LetterBizStatus.DELIVERING.getCode());
            letter.setSendMode(LetterSendMode.STANDARD_POST.getCode());
            letter.setExpectedArrivalTime(now.plusMinutes(ThreadLocalRandom.current().nextInt(10, 121)));
            letter.setActualArrivalTime(null);
        } else if (vip) {
            letter.setLetterType(LetterPhysicalType.REGISTERED.getCode());
            letter.setStatus(LetterBizStatus.DELIVERED.getCode());
            letter.setSendMode(LetterSendMode.DIRECT_VIP.getCode());
            letter.setExpectedArrivalTime(null);
            letter.setActualArrivalTime(now);
        } else {
            letter.setLetterType(LetterPhysicalType.REGISTERED.getCode());
            letter.setStatus(LetterBizStatus.DELIVERED.getCode());
            letter.setSendMode(LetterSendMode.REGISTERED_MAIL.getCode());
            letter.setExpectedArrivalTime(null);
            letter.setActualArrivalTime(now);
        }

        letter.initAudit(fromUserId);
        letterService.save(letter);
        // 发信后按规则重算写作风格（样本不足时内部跳过）
        writingStyleService.recompute(fromUserId);

        LetterDomain saved = letterService.getById(letter.getId());
        return toItem(saved, fromUserId, false);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public MailboxLetterItemVO getLetter(long viewerUserId, long letterId) {
        LetterDomain l = letterService.getById(letterId);
        if (l == null || l.isDelFlag()) {
            throw new BusinessException(appMessages.get("app.error.letter.notFound"));
        }
        if (l.getFromUserId() != viewerUserId && l.getToUserId() != viewerUserId) {
            throw new BusinessException(appMessages.get("app.error.letter.noPermissionView"));
        }
        if (Objects.equals(l.getToUserId(), viewerUserId)
                && l.getRecipientReadAt() == null
                && toInt(l.getStatus()) == LetterBizStatus.DELIVERED.getCode()) {
            boolean marked = letterService.update(new LambdaUpdateWrapper<LetterDomain>()
                    .eq(LetterDomain::getId, letterId)
                    .eq(LetterDomain::isDelFlag, false)
                    .eq(LetterDomain::getToUserId, viewerUserId)
                    .isNull(LetterDomain::getRecipientReadAt)
                    .set(LetterDomain::getRecipientReadAt, LocalDateTime.now())
                    .set(LetterDomain::getUpdatedAt, LocalDateTime.now())
                    .set(LetterDomain::getUpdatedBy, viewerUserId));
            if (marked) {
                l = letterService.getById(letterId);
            }
        }
        return toItem(l, viewerUserId, true);
    }

    @Override
    public List<MailboxFriendItemVO> listFriends(Long userId) {
        List<FriendshipDomain> rows = friendshipService.listActiveFriendshipsForUser(userId);
        List<MailboxFriendItemVO> out = new ArrayList<>();
        for (FriendshipDomain f : rows) {
            long low = f.getUserLow() != null ? f.getUserLow() : 0L;
            long high = f.getUserHigh() != null ? f.getUserHigh() : 0L;
            long peer = low == userId ? high : low;
            UserDTO peerDto = userService.findById(peer);
            if (peerDto == null) {
                continue;
            }
            String avatar = UserAvatarAuditSupport.publicStoredRef(peerDto);
            if (StringUtils.hasText(avatar)) {
                avatar = ossDisplayUrlService.signAvatarForViewer(userId, avatar.trim());
            }
            LocalDateTime connected = f.getUpdatedAt() != null ? f.getUpdatedAt() : f.getCreatedAt();
            out.add(MailboxFriendItemVO.builder()
                    .friendshipId(f.getId())
                    .peerUserId(peer)
                    .peerNickname(peerDto.getNickname())
                    .peerAvatarUrl(avatar)
                    .peerCountryCode(peerDto.getCountryCode())
                    .connectedAt(connected)
                    .build());
        }
        return out;
    }

    @Override
    public boolean isFriendshipActive(long viewerUserId, long peerUserId) {
        return friendshipService.areActiveFriends(viewerUserId, peerUserId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public MailboxLetterItemVO earlyOpenLetter(long actorUserId, long letterId) {
        LetterDomain letter = letterService.getById(letterId);
        if (letter == null || letter.isDelFlag()) {
            throw new BusinessException(appMessages.get("app.error.letter.notFound"));
        }
        if (letter.getToUserId() == null || !Objects.equals(letter.getToUserId(), actorUserId)) {
            throw new BusinessException(appMessages.get("app.error.letter.earlyOpenRecipientOnly"));
        }
        if (toInt(letter.getLetterType()) != LetterPhysicalType.STANDARD.getCode()) {
            throw new BusinessException(appMessages.get("app.error.letter.earlyOpenStandardOnly"));
        }
        if (toInt(letter.getStatus()) != LetterBizStatus.DELIVERING.getCode()) {
            throw new BusinessException(appMessages.get("app.error.letter.earlyOpenBadStatus"));
        }
        if (letter.getRecipientEarlyOpenAt() != null) {
            throw new BusinessException(appMessages.get("app.error.letter.earlyOpenAlready"));
        }
        UserDTO recipient = userService.findById(actorUserId);
        if (recipient == null || userStatus(recipient.getStatus()) != USER_STATUS_NORMAL) {
            throw new BusinessException(appMessages.get("app.error.account.statusAbnormal"));
        }
        boolean vip = Boolean.TRUE.equals(recipient.getIsVip());
        LocalDateTime now = LocalDateTime.now();
        boolean letterPatched = letterService.update(new LambdaUpdateWrapper<LetterDomain>()
                .eq(LetterDomain::getId, letterId)
                .eq(LetterDomain::isDelFlag, false)
                .eq(LetterDomain::getStatus, LetterBizStatus.DELIVERING.getCode())
                .eq(LetterDomain::getToUserId, actorUserId)
                .isNull(LetterDomain::getRecipientEarlyOpenAt)
                .set(LetterDomain::getRecipientEarlyOpenAt, now)
                // 收件人已付费拆信：对双方列表/归档与「已送达」语义一致，避免仍显示运输中
                .set(LetterDomain::getStatus, LetterBizStatus.DELIVERED.getCode())
                .set(LetterDomain::getActualArrivalTime, now)
                .set(LetterDomain::getRecipientReadAt, now)
                .set(LetterDomain::getUpdatedAt, now)
                .set(LetterDomain::getUpdatedBy, actorUserId));
        if (!letterPatched) {
            throw new BusinessException(appMessages.get("app.error.letter.stateChanged"));
        }
        LetterDomain saved = letterService.getById(letterId);
        return toItem(saved, actorUserId, true);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public MailboxLetterItemVO speedUpLetter(long actorUserId, long letterId) {
        LetterDomain letter = letterService.getById(letterId);
        if (letter == null || letter.isDelFlag()) {
            throw new BusinessException(appMessages.get("app.error.letter.notFound"));
        }
        if (letter.getFromUserId() != actorUserId) {
            throw new BusinessException(appMessages.get("app.error.letter.speedUpSenderOnly"));
        }
        if (toInt(letter.getLetterType()) != LetterPhysicalType.STANDARD.getCode()) {
            throw new BusinessException(appMessages.get("app.error.letter.speedUpStandardOnly"));
        }
        if (toInt(letter.getStatus()) != LetterBizStatus.DELIVERING.getCode()) {
            throw new BusinessException(appMessages.get("app.error.letter.speedUpBadStatus"));
        }
        if (Boolean.TRUE.equals(letter.getIsAccelerated())) {
            throw new BusinessException(appMessages.get("app.error.letter.speedUpAlready"));
        }

        UserDTO sender = userService.findById(actorUserId);
        if (sender == null || userStatus(sender.getStatus()) != USER_STATUS_NORMAL) {
            throw new BusinessException(appMessages.get("app.error.account.statusAbnormal"));
        }
        boolean vip = Boolean.TRUE.equals(sender.getIsVip());
        LocalDateTime now = LocalDateTime.now();

        boolean letterPatched = letterService.update(new LambdaUpdateWrapper<LetterDomain>()
                .eq(LetterDomain::getId, letterId)
                .eq(LetterDomain::isDelFlag, false)
                .eq(LetterDomain::getStatus, LetterBizStatus.DELIVERING.getCode())
                .eq(LetterDomain::getFromUserId, actorUserId)
                .set(LetterDomain::getStatus, LetterBizStatus.DELIVERED.getCode())
                .set(LetterDomain::getIsAccelerated, true)
                .set(LetterDomain::getAcceleratedAt, now)
                .set(LetterDomain::getActualArrivalTime, now)
                .set(LetterDomain::getUpdatedAt, now)
                .set(LetterDomain::getUpdatedBy, actorUserId));
        if (!letterPatched) {
            throw new BusinessException(appMessages.get("app.error.letter.stateChanged"));
        }

        LetterDomain saved = letterService.getById(letterId);
        return toItem(saved, actorUserId, false);
    }

    private static int userStatus(Object status) {
        if (status instanceof Number n) {
            return n.intValue();
        }
        if (status instanceof String s) {
            return Integer.parseInt(s);
        }
        return 0;
    }

    private List<LetterDomain> loadLettersForUser(Long userId, LocalDateTime since, int limit) {
        LambdaQueryWrapper<LetterDomain> q = new LambdaQueryWrapper<LetterDomain>()
                .eq(LetterDomain::isDelFlag, false)
                .and(w -> w.eq(LetterDomain::getFromUserId, userId).or().eq(LetterDomain::getToUserId, userId));
        if (since != null) {
            q.apply("COALESCE(updated_at, created_at) > {0}", since);
        }
        q.orderByDesc(LetterDomain::getUpdatedAt).last("LIMIT " + limit);
        return letterService.list(q);
    }

    private static long peerUserId(LetterDomain l, long viewer) {
        if (l.getFromUserId() == viewer) {
            return l.getToUserId();
        }
        return l.getFromUserId();
    }

    /**
     * Postal inbox：与 Connections/好友关系无关。
     * 收、发双方一致：只要本人是信件关联方，且收件方尚未产生「已读」时间
     * （{@code recipient_read_at == null}），即出现在邮政收件箱。
     * 这样挂号信（立即已送达）发件人也能在对方未读前看到该信；平邮运输中同理。
     */
    private static boolean includeInPostalInbox(LetterDomain l, long userId) {
        if (l == null || l.isDelFlag()) {
            return false;
        }
        if (!Objects.equals(l.getToUserId(), userId) && !Objects.equals(l.getFromUserId(), userId)) {
            return false;
        }
        return l.getRecipientReadAt() == null;
    }

    private MailboxLetterItemVO toItem(LetterDomain l, long viewer, boolean includeFullContent) {
        long peerId = peerUserId(l, viewer);
        UserDTO peer = userService.findById(peerId);
        boolean fromMe = Objects.equals(l.getFromUserId(), viewer);
        boolean delivering = toInt(l.getStatus()) == LetterBizStatus.DELIVERING.getCode();
        boolean standard = toInt(l.getLetterType()) == LetterPhysicalType.STANDARD.getCode();
        boolean openedEarly = l.getRecipientEarlyOpenAt() != null;
        boolean hideBody = !fromMe && delivering && standard && !openedEarly;

        String fullContent = l.getContent() != null ? l.getContent() : "";
        String preview;
        String contentOut = null;
        if (hideBody) {
            preview = "";
            if (includeFullContent) {
                contentOut = "";
            }
        } else {
            preview = fullContent.length() > 280 ? fullContent.substring(0, 280) + "…" : fullContent;
            if (includeFullContent) {
                contentOut = fullContent;
            }
        }
        AppPublicUserVO peerVo = toPublic(peer);
        String peerAvatarRef = UserAvatarAuditSupport.publicStoredRef(peer);
        if (StringUtils.hasText(peerAvatarRef)) {
            peerVo.setAvatarUrl(ossDisplayUrlService.signAvatarForViewer(viewer, peerAvatarRef));
        } else {
            peerVo.setAvatarUrl(null);
        }
        LocalDateTime expected = toLocalDateTimeField(l.getExpectedArrivalTime());
        LocalDateTime actual = toLocalDateTimeField(l.getActualArrivalTime());
        return MailboxLetterItemVO.builder()
                .letterId(l.getId())
                .peer(peerVo)
                .letterType(toInt(l.getLetterType()))
                .sendMode(l.getSendMode() != null ? l.getSendMode() : LetterSendMode.STANDARD_POST.getCode())
                .status(toInt(l.getStatus()))
                .preview(preview)
                .content(contentOut)
                .fromMe(fromMe)
                .sentAt(l.getCreatedAt())
                .updatedAt(l.getUpdatedAt())
                .expectedArrivalTime(expected)
                .actualArrivalTime(actual)
                .contentHidden(hideBody)
                .build();
    }

    private static LocalDateTime toLocalDateTimeField(Object raw) {
        if (raw == null) {
            return null;
        }
        if (raw instanceof LocalDateTime ldt) {
            return ldt;
        }
        if (raw instanceof java.sql.Timestamp ts) {
            return ts.toLocalDateTime();
        }
        return null;
    }

    private static AppPublicUserVO toPublic(UserDTO dto) {
        if (dto == null) {
            return AppPublicUserVO.builder().id(0L).nickname("unknown").build();
        }
        return AppPublicUserVO.builder()
                .id(dto.getId())
                .nickname(dto.getNickname())
                .gender(dto.getGender())
                .birthYear(dto.getBirthYear())
                .countryCode(dto.getCountryCode())
                .bio(dto.getBio())
                .avatarUrl(UserAvatarAuditSupport.publicStoredRef(dto))
                .isVip(dto.getIsVip())
                .build();
    }

    private static int toInt(Object o) {
        if (o instanceof Number n) {
            return n.intValue();
        }
        if (o instanceof String s) {
            return Integer.parseInt(s);
        }
        return 0;
    }
}
