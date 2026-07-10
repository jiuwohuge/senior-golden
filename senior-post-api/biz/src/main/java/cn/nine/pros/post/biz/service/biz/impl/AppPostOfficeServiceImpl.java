package cn.nine.pros.post.biz.service.biz.impl;

import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.model.domain.LetterDomain;
import cn.nine.pros.post.biz.service.base.ConfigService;
import cn.nine.pros.post.biz.service.base.LetterService;
import cn.nine.pros.post.biz.service.base.OssDisplayUrlService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.biz.service.biz.AppPostOfficeService;
import cn.nine.pros.post.biz.service.biz.AppRelationBizService;
import cn.nine.pros.post.biz.service.biz.support.UserAvatarAuditSupport;
import cn.nine.pros.post.biz.support.TextPreviewSupport;
import cn.nine.pros.post.client.common.enums.LetterBizStatus;
import cn.nine.pros.post.client.model.db.UserDTO;
import cn.nine.pros.post.client.model.out.AppPostOfficeHomeVO;
import cn.nine.pros.post.client.model.out.AppPublicUserVO;
import cn.nine.pros.post.client.model.out.PostOfficeInTransitItemVO;
import cn.nine.pros.post.client.model.out.PostOfficeRelationMessageVO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

@Slf4j
@Service
@RequiredArgsConstructor
public class AppPostOfficeServiceImpl implements AppPostOfficeService {

    private static final String LETTER_DAILY_QUOTA_KEY = "letter.daily_quota";
    private static final int DEFAULT_DAILY_LETTER_QUOTA = 5;
    private static final int IN_TRANSIT_TYPE_OUT = 1;
    private static final int IN_TRANSIT_TYPE_IN = 2;
    private static final int IN_TRANSIT_TYPE_UNREAD = 3;

    private final LetterService letterService;
    private final ConfigService configService;
    private final AppMessages appMessages;
    private final AppRelationBizService appRelationBizService;
    private final UserService userService;
    private final OssDisplayUrlService ossDisplayUrlService;

    @Override
    public AppPostOfficeHomeVO home(long userId) {
        LocalDateTime dayStart = LocalDate.now().atStartOfDay();
        LocalDateTime dayEnd = LocalDate.now().atTime(LocalTime.MAX);

        long sentToday = letterService.countSentQuotaByFromUserBetween(userId, dayStart, dayEnd);
        long outboundInTransit = letterService.countByFromUserAndStatus(
                userId, LetterBizStatus.DELIVERING.getCode());
        long outboundPending = letterService.countByFromUserAndStatus(
                userId, LetterBizStatus.PENDING.getCode());
        long inboundInTransit = letterService.countByToUserAndStatus(
                userId, LetterBizStatus.DELIVERING.getCode());
        long unreadDelivered = letterService.countUnreadDeliveredForToUser(userId);

        int inTransit = (int) (outboundInTransit + outboundPending + inboundInTransit + unreadDelivered);
        int relationCount = appRelationBizService.countRelationMessages(userId);

        AppPostOfficeHomeVO vo = AppPostOfficeHomeVO.builder()
                .greeting(appMessages.get("app.postOffice.greeting"))
                .todayHint(appMessages.get("app.postOffice.todayHint"))
                .dailyLetterQuota(configService.getInt(LETTER_DAILY_QUOTA_KEY, DEFAULT_DAILY_LETTER_QUOTA))
                .sentToday((int) sentToday)
                .relationMessageCount(relationCount)
                .inTransitCount(inTransit)
                .outboundInTransit((int) (outboundInTransit + outboundPending))
                .inboundInTransit((int) inboundInTransit)
                .unreadDelivered((int) unreadDelivered)
                .build();
        log.debug("post-office home userId={}, sentToday={}, inTransit={}", userId, sentToday, inTransit);
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

    private void appendOutbound(long userId, List<PostOfficeInTransitItemVO> out) {
        List<LetterDomain> sent = letterService.listSentForUser(userId, 100);
        for (LetterDomain l : sent) {
            int st = statusInt(l.getStatus());
            if (st != LetterBizStatus.DELIVERING.getCode()
                    && st != LetterBizStatus.PENDING.getCode()
                    && st != LetterBizStatus.MATCHED.getCode()) {
                continue;
            }
            if (l.getToUserId() == null) {
                continue;
            }
            out.add(buildTransitItem(userId, l, IN_TRANSIT_TYPE_OUT));
        }
    }

    private void appendInbound(long userId, List<PostOfficeInTransitItemVO> out) {
        List<LetterDomain> received = letterService.listReceivedForUser(userId, 100);
        for (LetterDomain l : received) {
            if (statusInt(l.getStatus()) != LetterBizStatus.DELIVERING.getCode()) {
                continue;
            }
            out.add(buildTransitItem(userId, l, IN_TRANSIT_TYPE_IN));
        }
    }

    private void appendUnread(long userId, List<PostOfficeInTransitItemVO> out) {
        List<LetterDomain> received = letterService.listReceivedForUser(userId, 100);
        for (LetterDomain l : received) {
            if (statusInt(l.getStatus()) != LetterBizStatus.DELIVERED.getCode()) {
                continue;
            }
            if (l.getRecipientReadAt() != null) {
                continue;
            }
            out.add(buildTransitItem(userId, l, IN_TRANSIT_TYPE_UNREAD));
        }
    }

    private PostOfficeInTransitItemVO buildTransitItem(long viewerUserId, LetterDomain l, int itemType) {
        long peerId = Objects.equals(l.getFromUserId(), viewerUserId)
                ? (l.getToUserId() != null ? l.getToUserId() : 0L)
                : (l.getFromUserId() != null ? l.getFromUserId() : 0L);
        String preview = TextPreviewSupport.previewOrHidden(false, l.getContent(), 120);
        return PostOfficeInTransitItemVO.builder()
                .itemType(itemType)
                .letterId(l.getId())
                .peer(toPublic(viewerUserId, peerId))
                .expectedArrivalTime(toLocalDateTime(l.getExpectedArrivalTime()))
                .preview(preview)
                .build();
    }

    private AppPublicUserVO toPublic(long viewerUserId, long userId) {
        if (userId <= 0) {
            return AppPublicUserVO.builder().id(0L).nickname("?").build();
        }
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

    private static int statusInt(Object status) {
        if (status instanceof Number n) {
            return n.intValue();
        }
        if (status instanceof String s) {
            return Integer.parseInt(s);
        }
        return 0;
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
