package cn.nine.pros.post.biz.service.biz.support;

import cn.nine.pros.post.biz.model.domain.UserDomain;
import cn.nine.pros.post.biz.service.base.ConfigService;
import cn.nine.pros.post.client.model.db.UserDTO;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.concurrent.ThreadLocalRandom;

/**
 * 匹配/推荐共用打分辅助（§7.3 可配置权重 + §7.4 分发比例）。
 */
@Component
@RequiredArgsConstructor
public class MatchScoringSupport {

    private static final String KEY_SCORE_EMOTION = "match.score.emotion";
    private static final String KEY_SCORE_INTEREST = "match.score.interest";
    private static final String KEY_SCORE_STYLE = "match.score.style";
    private static final String KEY_SCORE_TIME = "match.score.time";
    private static final String KEY_SCORE_GEO = "match.score.geo";
    private static final String KEY_SCORE_FRESHNESS = "match.score.freshness";
    private static final String KEY_SCORE_EXPLORE = "match.score.explore";
    private static final String KEY_DIST_HIGH = "match.distribution.high";
    private static final String KEY_DIST_MID = "match.distribution.mid";
    private static final String KEY_AI_EMOTION = "match.ai.emotion_enabled";
    private static final String KEY_AI_STYLE = "match.ai.style_enabled";

    private final ConfigService configService;

    @Getter
    public enum DistributionBucket {
        HIGH,
        MID,
        EXPLORE
    }

    /**
     * 按 sys_config 权重对候选用户加权打分（0~1 归一化分量 × 权重求和）。
     */
    public double scoreCandidateWeighted(
            UserDTO viewer,
            UserDomain cand,
            List<Integer> viewerTagIds,
            List<Integer> candTagIds,
            boolean viewerProtected,
            int protectN,
            long candSentCount,
            Double aiEmotionScore,
            Double aiStyleScore) {
        if (cand.getId() == null || viewer.getId() == null) {
            return Double.NEGATIVE_INFINITY;
        }
        if (cand.getId().equals(viewer.getId())) {
            return Double.NEGATIVE_INFINITY;
        }

        double wEmotion = configService.getDouble(KEY_SCORE_EMOTION, 0.30);
        double wInterest = configService.getDouble(KEY_SCORE_INTEREST, 0.20);
        double wStyle = configService.getDouble(KEY_SCORE_STYLE, 0.15);
        double wTime = configService.getDouble(KEY_SCORE_TIME, 0.10);
        double wGeo = configService.getDouble(KEY_SCORE_GEO, 0.10);
        double wFreshness = configService.getDouble(KEY_SCORE_FRESHNESS, 0.10);
        double wExplore = configService.getDouble(KEY_SCORE_EXPLORE, 0.05);

        boolean aiEmotionEnabled = configFlag(KEY_AI_EMOTION, false);
        boolean aiStyleEnabled = configFlag(KEY_AI_STYLE, false);

        double interestNorm = normalizeInterest(viewerTagIds, candTagIds);
        double styleNorm = normalizeStyle(viewer.getWritingStyle(), cand.getWritingStyle(), aiStyleScore, aiStyleEnabled);
        double geoNorm = normalizeGeo(viewer, cand);
        double freshnessNorm = candSentCount < protectN ? 1.0 : 0.0;
        double timeNorm = 0.5;
        double exploreNorm = ThreadLocalRandom.current().nextDouble();
        double emotionNorm = interestNorm;
        if (aiEmotionEnabled && aiEmotionScore != null) {
            emotionNorm = clamp01(aiEmotionScore);
        } else {
            wInterest += wEmotion;
            wEmotion = 0.0;
        }

        double score = wEmotion * emotionNorm
                + wInterest * interestNorm
                + wStyle * styleNorm
                + wTime * timeNorm
                + wGeo * geoNorm
                + wFreshness * freshnessNorm
                + wExplore * exploreNorm;

        if (viewerProtected) {
            score += wFreshness * 0.2;
        }
        return score;
    }

    /** 简化入口：无 AI 特征时使用。 */
    public double scoreCandidate(
            UserDTO viewer,
            UserDomain cand,
            List<Integer> viewerTagIds,
            List<Integer> candTagIds,
            boolean viewerProtected,
            int protectN,
            long candSentCount) {
        return scoreCandidateWeighted(
                viewer, cand, viewerTagIds, candTagIds,
                viewerProtected, protectN, candSentCount, null, null);
    }

    /**
     * 按 match.distribution.* 配置随机选取分发档位（默认 60/30/10）。
     */
    public DistributionBucket pickDistributionBucket() {
        double high = configService.getDouble(KEY_DIST_HIGH, 0.60);
        double mid = configService.getDouble(KEY_DIST_MID, 0.30);
        double r = ThreadLocalRandom.current().nextDouble();
        if (r < high) {
            return DistributionBucket.HIGH;
        }
        if (r < high + mid) {
            return DistributionBucket.MID;
        }
        return DistributionBucket.EXPLORE;
    }

    public static String resolveReasonKey(UserDTO viewer, UserDomain cand, List<Integer> viewerTags, List<Integer> candTags) {
        int shared = countShared(viewerTags, candTags);
        if (shared >= 2) {
            return "recommend.reason.interestMatch";
        }
        if (sameIgnoreCase(viewer.getCountryCode(), cand.getCountryCode())) {
            return "recommend.reason.sameCountry";
        }
        if (sameIgnoreCase(viewer.getLanguage(), cand.getLanguage())) {
            return "recommend.reason.sameLanguage";
        }
        return "recommend.reason.explore";
    }

    public static boolean languageCompatible(String a, String b) {
        if (!StringUtils.hasText(a) || !StringUtils.hasText(b)) {
            return true;
        }
        String la = a.trim().toLowerCase();
        String lb = b.trim().toLowerCase();
        if (la.equals(lb)) {
            return true;
        }
        return la.startsWith("zh") && lb.startsWith("zh")
                || la.startsWith("en") && lb.startsWith("en");
    }

    private boolean configFlag(String key, boolean defaultValue) {
        var cfg = configService.findActiveByKey(key);
        if (cfg == null || cfg.getConfigValue() == null || cfg.getConfigValue().isBlank()) {
            return defaultValue;
        }
        return "true".equalsIgnoreCase(cfg.getConfigValue().trim());
    }

    private static double normalizeInterest(List<Integer> viewerTagIds, List<Integer> candTagIds) {
        if (viewerTagIds == null || viewerTagIds.isEmpty() || candTagIds == null || candTagIds.isEmpty()) {
            return 0.0;
        }
        Set<Integer> viewerTagSet = new HashSet<>(viewerTagIds);
        int shared = 0;
        for (Integer t : candTagIds) {
            if (viewerTagSet.contains(t)) {
                shared++;
            }
        }
        int denom = Math.max(viewerTagIds.size(), candTagIds.size());
        return clamp01((double) shared / denom);
    }

    private static double normalizeStyle(String viewerStyle, String candStyle, Double aiStyleScore, boolean aiStyleEnabled) {
        if (aiStyleEnabled && aiStyleScore != null) {
            return clamp01(aiStyleScore);
        }
        if (!StringUtils.hasText(viewerStyle) || !StringUtils.hasText(candStyle)) {
            return 0.0;
        }
        return viewerStyle.trim().equalsIgnoreCase(candStyle.trim()) ? 1.0 : 0.0;
    }

    private static double normalizeGeo(UserDTO viewer, UserDomain cand) {
        double geo = 0.0;
        if (sameIgnoreCase(viewer.getLanguage(), cand.getLanguage())) {
            geo += 0.5;
        }
        if (sameIgnoreCase(viewer.getCountryCode(), cand.getCountryCode())) {
            geo += 0.5;
        }
        return geo;
    }

    private static double clamp01(double v) {
        if (v < 0.0) {
            return 0.0;
        }
        if (v > 1.0) {
            return 1.0;
        }
        return v;
    }

    private static int countShared(List<Integer> a, List<Integer> b) {
        if (a == null || b == null || a.isEmpty() || b.isEmpty()) {
            return 0;
        }
        Set<Integer> set = new HashSet<>(a);
        int n = 0;
        for (Integer t : b) {
            if (set.contains(t)) {
                n++;
            }
        }
        return n;
    }

    private static boolean sameIgnoreCase(String a, String b) {
        if (!StringUtils.hasText(a) || !StringUtils.hasText(b)) {
            return false;
        }
        return a.trim().equalsIgnoreCase(b.trim());
    }
}
