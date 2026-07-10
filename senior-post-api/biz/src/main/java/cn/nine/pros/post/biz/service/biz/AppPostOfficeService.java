package cn.nine.pros.post.biz.service.biz;

import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.service.base.ConfigService;
import cn.nine.pros.post.biz.service.base.LetterService;
import cn.nine.pros.post.client.common.enums.LetterBizStatus;
import cn.nine.pros.post.client.model.out.AppPostOfficeHomeVO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

/**
 * 邮局首页聚合（§11）：问候、额度、关系/在途摘要计数。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AppPostOfficeService {

    private static final String LETTER_DAILY_QUOTA_KEY = "letter.daily_quota";
    private static final int DEFAULT_DAILY_LETTER_QUOTA = 5;

    private final LetterService letterService;
    private final ConfigService configService;
    private final AppMessages appMessages;

    /**
     * 构建当前登录用户的邮局首页数据。
     */
    public AppPostOfficeHomeVO home(long userId) {
        LocalDateTime dayStart = LocalDate.now().atStartOfDay();
        LocalDateTime dayEnd = LocalDate.now().atTime(LocalTime.MAX);

        long sentToday = letterService.countSentByFromUserBetween(userId, dayStart, dayEnd);
        long outboundInTransit = letterService.countByFromUserAndStatus(
                userId, LetterBizStatus.DELIVERING.getCode());
        // POST_OFFICE 入池也算「在路上」摘要的一部分（待匹配）
        long outboundPending = letterService.countByFromUserAndStatus(
                userId, LetterBizStatus.PENDING.getCode());
        long inboundInTransit = letterService.countByToUserAndStatus(
                userId, LetterBizStatus.DELIVERING.getCode());
        long unreadDelivered = letterService.countUnreadDeliveredForToUser(userId);

        int inTransit = (int) (outboundInTransit + outboundPending + inboundInTransit + unreadDelivered);
        // 笔友申请模型尚未独立表：M2 关系摘要先返回 0，M4 补齐
        int relationCount = 0;

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
}
