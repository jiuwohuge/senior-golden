package cn.nine.pros.post.biz.service.biz.impl;

import cn.nine.commons.basic.exception.unchecked.BusinessException;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.model.domain.DailyQuotaClaimDomain;
import cn.nine.pros.post.biz.model.domain.LetterDomain;
import cn.nine.pros.post.biz.service.base.ConfigService;
import cn.nine.pros.post.biz.service.base.DailyQuotaClaimService;
import cn.nine.pros.post.biz.service.base.LetterService;
import cn.nine.pros.post.biz.service.base.OssDisplayUrlService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.biz.service.biz.AppPostOfficeService;
import cn.nine.pros.post.biz.service.biz.AppRelationBizService;
import cn.nine.pros.post.biz.service.biz.support.DailyQuotaSupport;
import cn.nine.pros.post.biz.service.biz.support.UserAvatarAuditSupport;
import cn.nine.pros.post.biz.support.TextPreviewSupport;
import cn.nine.pros.post.client.model.db.UserDTO;
import cn.nine.pros.post.client.model.out.AppPostOfficeHomeVO;
import cn.nine.pros.post.client.model.out.AppPublicUserVO;
import cn.nine.pros.post.client.model.out.DailyQuotaClaimVO;
import cn.nine.pros.post.client.model.out.PostOfficeInTransitItemVO;
import cn.nine.pros.post.client.model.out.PostOfficeRelationMessageVO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

@Slf4j
@Service
@RequiredArgsConstructor
public class AppPostOfficeServiceImpl implements AppPostOfficeService {

    private static final int IN_TRANSIT_TYPE_OUT = 1;
    private static final int IN_TRANSIT_TYPE_IN = 2;
    private static final int IN_TRANSIT_TYPE_UNREAD = 3;

    private final LetterService letterService;
    private final ConfigService configService;
    private final AppMessages appMessages;
    private final AppRelationBizService appRelationBizService;
    private final UserService userService;
    private final OssDisplayUrlService ossDisplayUrlService;
    private final DailyQuotaClaimService dailyQuotaClaimService;

    @Override
    public AppPostOfficeHomeVO home(long userId) {
        UserDTO user = userService.findById(userId);
        DailyQuotaSupport.Snapshot snap = DailyQuotaSupport.resolve(
                userId, user, configService, dailyQuotaClaimService, letterService);

        long outboundInTransit = letterService.countOutboundInTransit(userId);
        long inboundInTransit = letterService.countInboundInTransit(userId);
        long unreadDelivered = letterService.countUnreadDeliveredForToUser(userId);

        int inTransit = (int) (outboundInTransit + inboundInTransit + unreadDelivered);
        int relationCount = appRelationBizService.countRelationMessages(userId);

        AppPostOfficeHomeVO vo = AppPostOfficeHomeVO.builder()
                .greeting(appMessages.get("app.postOffice.greeting"))
                .todayHint(appMessages.get("app.postOffice.todayHint"))
                .dailyLetterQuota(snap.configQuota())
                .sentToday(snap.sentToday())
                .quotaClaimedToday(snap.claimed())
                .remainingQuota(snap.remaining())
                .firstLetterDone(user != null && Boolean.TRUE.equals(user.getFirstLetterDone()))
                .relationMessageCount(relationCount)
                .inTransitCount(inTransit)
                .outboundInTransit((int) outboundInTransit)
                .inboundInTransit((int) inboundInTransit)
                .unreadDelivered((int) unreadDelivered)
                .build();
        log.debug("post-office home userId={}, claimed={}, sentToday={}, remaining={}, inTransit={}",
                userId, snap.claimed(), snap.sentToday(), snap.remaining(), inTransit);
        return vo;
    }

    @Override
    public List<PostOfficeRelationMessageVO> listRelationMessages(long userId) {
        return appRelationBizService.listRelationMessages(userId);
    }

    @Override
    public List<PostOfficeInTransitItemVO> listInTransit(long userId) {
        List<PostOfficeInTransitItemVO> out = new ArrayList<>();
        appendOutbound(userId, out);
        appendInbound(userId, out);
        appendUnread(userId, out);
        return out;
    }

    @Override
    public DailyQuotaClaimVO claimDailyQuota(long userId) {
        int quota = DailyQuotaSupport.configQuota(configService);
        LocalDate today = LocalDate.now();
        DailyQuotaClaimDomain row = dailyQuotaClaimService.claim(userId, today, quota, userId);
        if (row == null) {
            throw new BusinessException(appMessages.get("app.error.letter.quotaClaimFailed"));
        }
        UserDTO user = userService.findById(userId);
        DailyQuotaSupport.Snapshot snap = DailyQuotaSupport.resolve(
                userId, user, configService, dailyQuotaClaimService, letterService);
        log.info("daily quota claim ok, userId={}, remaining={}", userId, snap.remaining());
        return DailyQuotaClaimVO.builder()
                .claimed(true)
                .dailyLetterQuota(snap.configQuota())
                .sentToday(snap.sentToday())
                .remainingQuota(snap.remaining())
                .build();
    }

    private void appendOutbound(long userId, List<PostOfficeInTransitItemVO> out) {
        for (LetterDomain l : letterService.listOutboundInTransit(userId, 100)) {
            out.add(buildTransitItem(userId, l, IN_TRANSIT_TYPE_OUT));
        }
    }

    private void appendInbound(long userId, List<PostOfficeInTransitItemVO> out) {
        for (LetterDomain l : letterService.listInboundDelivering(userId, 100)) {
            out.add(buildTransitItem(userId, l, IN_TRANSIT_TYPE_IN));
        }
    }

    private void appendUnread(long userId, List<PostOfficeInTransitItemVO> out) {
        for (LetterDomain l : letterService.listUnreadDelivered(userId, 100)) {
            out.add(buildTransitItem(userId, l, IN_TRANSIT_TYPE_UNREAD));
        }
    }

    private PostOfficeInTransitItemVO buildTransitItem(long viewerUserId, LetterDomain l, int itemType) {
        long peerId = Objects.equals(l.getFromUserId(), viewerUserId)
                ? (l.getToUserId() != null ? l.getToUserId() : 0L)
                : (l.getFromUserId() != null ? l.getFromUserId() : 0L);
        String preview = TextPreviewSupport.previewOrHidden(false, l.getContent(), 120);
        LocalDateTime sent = toLocalDateTime(l.getCreatedAt());
        LocalDateTime eta = toLocalDateTime(l.getExpectedArrivalTime());
        LocalDateTime now = LocalDateTime.now();
        Double etaHours = null;
        Double progress = null;
        if (eta != null && itemType != IN_TRANSIT_TYPE_UNREAD) {
            long minutes = ChronoUnit.MINUTES.between(now, eta);
            etaHours = Math.max(0, minutes) / 60.0;
            if (sent != null && eta.isAfter(sent)) {
                long total = ChronoUnit.MINUTES.between(sent, eta);
                long done = ChronoUnit.MINUTES.between(sent, now);
                if (total > 0) {
                    progress = Math.min(1.0, Math.max(0.0, (double) done / (double) total));
                }
            }
        } else if (itemType == IN_TRANSIT_TYPE_UNREAD) {
            progress = 1.0;
            etaHours = 0.0;
        }
        return PostOfficeInTransitItemVO.builder()
                .itemType(itemType)
                .letterId(l.getId())
                .peer(toPublic(viewerUserId, peerId))
                .sentTime(sent)
                .expectedArrivalTime(eta)
                .etaRelativeHours(etaHours)
                .progressRatio(progress)
                .preview(preview)
                .build();
    }

    private AppPublicUserVO toPublic(long viewerUserId, long userId) {
        if (userId <= 0) {
            // 未配对：不回传 "?"，由客户端展示「推荐中」等本地化文案。
            return AppPublicUserVO.builder().id(0L).nickname("").build();
        }
        UserDTO dto = userService.findById(userId);
        if (dto == null) {
            return AppPublicUserVO.builder().id(userId).nickname("").build();
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

    private static LocalDateTime toLocalDateTime(Object raw) {
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
}
