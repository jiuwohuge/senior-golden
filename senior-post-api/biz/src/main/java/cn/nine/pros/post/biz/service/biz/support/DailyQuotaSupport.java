package cn.nine.pros.post.biz.service.biz.support;

import cn.nine.pros.post.biz.model.domain.DailyQuotaClaimDomain;
import cn.nine.pros.post.biz.service.base.ConfigService;
import cn.nine.pros.post.biz.service.base.DailyQuotaClaimService;
import cn.nine.pros.post.biz.service.base.LetterService;
import cn.nine.pros.post.biz.service.base.TimeLetterService;
import cn.nine.pros.post.client.model.db.UserDTO;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

/**
 * 每日免费发信额度：邮局信 + 已封存时光信共用 {@code letter.daily_quota}；
 * 管理员改过当日 cap 时以 claim.quota_amount 为准，未使用不跨日累计。
 */
public final class DailyQuotaSupport {

    public static final String LETTER_DAILY_QUOTA_KEY = "letter.daily_quota";
    public static final int DEFAULT_DAILY_LETTER_QUOTA = 5;

    private DailyQuotaSupport() {
    }

    /**
     * 当日额度快照。
     *
     * @param claimed     是否已领取（或 VIP 视为已领）
     * @param cap         当日上限（claim.quota_amount；未领为 0）
     * @param sentToday   今日已计入额度的发信数（标准信 + 已封存时光信）
     * @param remaining   剩余次数
     * @param vip         是否 VIP
     * @param configQuota 全局配置默认额度（展示用）
     */
    public record Snapshot(
            boolean claimed,
            int cap,
            int sentToday,
            int remaining,
            boolean vip,
            int configQuota) {
    }

    public static int configQuota(ConfigService configService) {
        return configService.getInt(LETTER_DAILY_QUOTA_KEY, DEFAULT_DAILY_LETTER_QUOTA);
    }

    /**
     * 解析用户当日额度；VIP 展示剩余=配置值且不拦截发信。
     */
    public static Snapshot resolve(
            long userId,
            UserDTO user,
            ConfigService configService,
            DailyQuotaClaimService dailyQuotaClaimService,
            LetterService letterService,
            TimeLetterService timeLetterService) {
        LocalDate today = LocalDate.now();
        int configQuota = configQuota(configService);
        LocalDateTime dayStart = today.atStartOfDay();
        LocalDateTime dayEnd = today.atTime(LocalTime.MAX);
        int lettersToday = (int) letterService.countSentQuotaByFromUserBetween(userId, dayStart, dayEnd);
        int timeLettersToday = (int) timeLetterService.countSealedQuotaBySenderBetween(
                userId, dayStart, dayEnd);
        int sentToday = lettersToday + timeLettersToday;
        boolean vip = user != null && Boolean.TRUE.equals(user.getIsVip());
        DailyQuotaClaimDomain claim = dailyQuotaClaimService.findClaim(userId, today);
        // 冷启动：未领取也按配置额度静默发放，不再拦截发信。
        boolean claimed = true;
        int cap = configQuota;
        if (claim != null && claim.getQuotaAmount() != null) {
            cap = claim.getQuotaAmount();
        }
        int remaining;
        if (vip) {
            remaining = configQuota;
        } else {
            remaining = Math.max(0, cap - sentToday);
        }
        return new Snapshot(claimed, cap, sentToday, remaining, vip, configQuota);
    }
}
