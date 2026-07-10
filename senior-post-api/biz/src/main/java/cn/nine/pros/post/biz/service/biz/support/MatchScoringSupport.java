package cn.nine.pros.post.biz.service.biz.support;

import cn.nine.pros.post.biz.model.domain.UserDomain;
import cn.nine.pros.post.client.model.db.UserDTO;
import org.springframework.util.StringUtils;

import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.concurrent.ThreadLocalRandom;

/**
 * 匹配/推荐共用打分辅助（§7 / §9）。
 */
public final class MatchScoringSupport {

    private MatchScoringSupport() {
    }

    public static double scoreCandidate(
            UserDTO viewer,
            UserDomain cand,
            List<Integer> viewerTagIds,
            List<Integer> candTagIds,
            boolean viewerProtected,
            int protectN,
            long candSentCount) {
        if (cand.getId() == null || viewer.getId() == null) {
            return Double.NEGATIVE_INFINITY;
        }
        if (cand.getId().equals(viewer.getId())) {
            return Double.NEGATIVE_INFINITY;
        }
        double score = ThreadLocalRandom.current().nextDouble(0, 1.0);
        Set<Integer> viewerTagSet = new HashSet<>(viewerTagIds != null ? viewerTagIds : List.of());
        int shared = 0;
        if (candTagIds != null) {
            for (Integer t : candTagIds) {
                if (viewerTagSet.contains(t)) {
                    shared++;
                }
            }
        }
        score += shared * 3.0;
        score += writingStyleBonus(viewer.getWritingStyle(), cand.getWritingStyle());
        if (sameIgnoreCase(viewer.getLanguage(), cand.getLanguage())) {
            score += 2.0;
        }
        if (sameIgnoreCase(viewer.getCountryCode(), cand.getCountryCode())) {
            score += 1.5;
        }
        if (candSentCount < protectN) {
            score += 5.0;
        }
        if (viewerProtected) {
            score += 2.0;
        }
        return score;
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

    private static double writingStyleBonus(String a, String b) {
        if (!StringUtils.hasText(a) || !StringUtils.hasText(b)) {
            return 0;
        }
        if (a.trim().equalsIgnoreCase(b.trim())) {
            return 2.5;
        }
        return 0;
    }

    private static boolean sameIgnoreCase(String a, String b) {
        if (!StringUtils.hasText(a) || !StringUtils.hasText(b)) {
            return false;
        }
        return a.trim().equalsIgnoreCase(b.trim());
    }
}
