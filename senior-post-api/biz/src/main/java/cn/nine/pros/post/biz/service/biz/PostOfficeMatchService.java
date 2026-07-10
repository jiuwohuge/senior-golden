package cn.nine.pros.post.biz.service.biz;

import cn.nine.pros.post.biz.model.domain.LetterDomain;
import cn.nine.pros.post.biz.model.domain.UserDomain;
import cn.nine.pros.post.biz.service.base.ConfigService;
import cn.nine.pros.post.biz.service.base.LetterService;
import cn.nine.pros.post.biz.service.base.UserBlacklistService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.biz.service.base.UserTagService;
import cn.nine.pros.post.biz.service.biz.support.DeliveryDelayCalculator;
import cn.nine.pros.post.biz.service.biz.support.MatchFeatureExtractionService;
import cn.nine.pros.post.biz.service.biz.support.MatchScoringSupport;
import cn.nine.pros.post.biz.service.biz.support.UserPreferenceSupport;
import cn.nine.pros.post.client.common.enums.LetterAuditStatus;
import cn.nine.pros.post.client.model.db.UserDTO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Objects;
import java.util.Set;

/**
 * POST_OFFICE 匹配 v2：过滤 → 可配置加权打分 → 60/30/10 分发 → 赋收件人 → 启运。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class PostOfficeMatchService {

    private static final String KEY_INBOUND_CAP = "match.inbound_daily_cap";
    private static final String KEY_BATCH = "match.batch_size";
    private static final String KEY_PROTECT = "match.new_user_protect_count";
    private static final String KEY_CANDIDATES = "match.candidate_pool_size";
    private static final String KEY_AUTO_APPROVE_SEC = "audit.auto_approve_seconds";

    private final LetterService letterService;
    private final UserService userService;
    private final UserTagService userTagService;
    private final UserBlacklistService userBlacklistService;
    private final ConfigService configService;
    private final DeliveryDelayCalculator deliveryDelayCalculator;
    private final MatchScoringSupport matchScoringSupport;
    private final MatchFeatureExtractionService matchFeatureExtractionService;
    private final UserPreferenceSupport userPreferenceSupport;

    /**
     * 自动放行超时 PENDING_REVIEW，再 drain 匹配池一批。
     * @return 成功匹配并启运的信件数
     */
    public int runMatchBatch(LocalDateTime now) {
        autoApproveOverdue(now);
        int batch = Math.max(1, configService.getInt(KEY_BATCH, 50));
        List<LetterDomain> pool = letterService.listPostOfficePendingPool(batch);
        int matched = 0;
        for (LetterDomain letter : pool) {
            if (matchOne(letter, now)) {
                matched++;
            }
        }
        if (matched > 0 || !pool.isEmpty()) {
            log.info("POST_OFFICE match batch: pooled={}, matched={}", pool.size(), matched);
        }
        return matched;
    }

    /**
     * 将创建时间早于阈值的 PENDING_REVIEW 自动 APPROVED。
     */
    public int autoApproveOverdue(LocalDateTime now) {
        int seconds = Math.max(0, configService.getInt(KEY_AUTO_APPROVE_SEC, 0));
        LocalDateTime before = now.minusSeconds(seconds);
        List<LetterDomain> pending = letterService.listPendingReviewBefore(before, 200);
        int n = 0;
        for (LetterDomain row : pending) {
            if (row.getId() == null) {
                continue;
            }
            if (letterService.approveAudit(row.getId(), now, 0L)) {
                n++;
            }
        }
        if (n > 0) {
            log.info("auto-approved PENDING_REVIEW letters, count={}", n);
        }
        return n;
    }

    @Transactional(rollbackFor = Exception.class)
    public boolean matchOne(LetterDomain letter, LocalDateTime now) {
        if (letter == null || letter.getId() == null || letter.getFromUserId() == null) {
            return false;
        }
        ensureApprovedForMatch(letter, now);
        LetterDomain fresh = letterService.getById(letter.getId());
        if (fresh == null || fresh.isDelFlag()) {
            return false;
        }
        if (Objects.equals(fresh.getAuditStatus(), LetterAuditStatus.REJECTED.getCode())) {
            return false;
        }
        if (!Objects.equals(fresh.getAuditStatus(), LetterAuditStatus.APPROVED.getCode())) {
            return false;
        }

        UserDTO sender = userService.findById(fresh.getFromUserId());
        if (sender == null) {
            return false;
        }

        Long recipientId = pickBestRecipient(fresh, sender, now);
        if (recipientId == null) {
            log.debug("no match candidate for letterId={}", fresh.getId());
            return false;
        }
        if (!letterService.tryAssignMatch(fresh.getId(), recipientId, now)) {
            return false;
        }
        UserDTO recipient = userService.findById(recipientId);
        LocalDateTime eta = deliveryDelayCalculator.expectedArrival(now, sender, recipient);
        boolean started = letterService.startDeliveringAfterMatch(fresh.getId(), eta, now);
        if (started) {
            log.info("POST_OFFICE matched, letterId={}, from={}, to={}, eta={}",
                    fresh.getId(), fresh.getFromUserId(), recipientId, eta);
        }
        return started;
    }

    private void ensureApprovedForMatch(LetterDomain letter, LocalDateTime now) {
        if (Objects.equals(letter.getAuditStatus(), LetterAuditStatus.APPROVED.getCode())) {
            return;
        }
        if (Objects.equals(letter.getAuditStatus(), LetterAuditStatus.REJECTED.getCode())) {
            return;
        }
        letterService.approveAudit(letter.getId(), now, 0L);
    }

    private Long pickBestRecipient(LetterDomain letter, UserDTO sender, LocalDateTime now) {
        int candidateLimit = Math.max(20, configService.getInt(KEY_CANDIDATES, 200));
        int inboundCap = Math.max(1, configService.getInt(KEY_INBOUND_CAP, 10));
        int protectN = Math.max(0, configService.getInt(KEY_PROTECT, 3));
        LocalDateTime dayStart = LocalDate.now().atStartOfDay();

        MatchFeatureExtractionService.LetterFeatures features =
                matchFeatureExtractionService.extractFromLetterContent(letter.getContent());

        List<UserDomain> candidates = userService.listActiveAppUsersExcluding(sender.getId(), candidateLimit);
        List<Integer> senderTags = userTagService.listTagIdsByUserId(sender.getId());
        Set<Integer> senderTagSet = new HashSet<>(senderTags);
        boolean senderProtected = letterService.countLettersSentByUser(sender.getId()) <= protectN;

        List<ScoredCandidate> scored = new ArrayList<>();
        for (UserDomain cand : candidates) {
            Double score = scoreCandidate(sender, cand, senderTagSet, senderProtected,
                    protectN, inboundCap, dayStart, features);
            if (score == null) {
                continue;
            }
            scored.add(new ScoredCandidate(cand.getId(), score));
        }
        if (scored.isEmpty()) {
            return null;
        }
        scored.sort(Comparator.comparingDouble(ScoredCandidate::score).reversed());

        MatchScoringSupport.DistributionBucket bucket = matchScoringSupport.pickDistributionBucket();
        ScoredCandidate picked = pickFromBucket(scored, bucket);
        if (picked != null) {
            return picked.userId();
        }
        return scored.get(0).userId();
    }

    private ScoredCandidate pickFromBucket(
            List<ScoredCandidate> sorted,
            MatchScoringSupport.DistributionBucket bucket) {
        if (sorted.isEmpty()) {
            return null;
        }
        int size = sorted.size();
        int third = Math.max(1, size / 3);
        int from;
        int to;
        switch (bucket) {
            case HIGH -> {
                from = 0;
                to = third;
            }
            case MID -> {
                from = third;
                to = Math.min(2 * third, size);
            }
            default -> {
                from = Math.min(2 * third, size);
                to = size;
            }
        }
        for (int i = from; i < to; i++) {
            return sorted.get(i);
        }
        return sorted.get(0);
    }

    /**
     * @return null 表示过滤掉；否则为打分
     */
    private Double scoreCandidate(
            UserDTO sender,
            UserDomain cand,
            Set<Integer> senderTagSet,
            boolean senderProtected,
            int protectN,
            int inboundCap,
            LocalDateTime dayStart,
            MatchFeatureExtractionService.LetterFeatures features) {
        if (cand.getId() == null || Objects.equals(cand.getId(), sender.getId())) {
            return null;
        }
        if (userPreferenceSupport.rejectStrangerLetters(cand.getId())) {
            return null;
        }
        if (userBlacklistService.existsActiveBlock(sender.getId(), cand.getId())
                || userBlacklistService.existsActiveBlock(cand.getId(), sender.getId())) {
            return null;
        }
        long inboundToday = letterService.countInboundPostOfficeSince(cand.getId(), dayStart);
        if (inboundToday >= inboundCap) {
            return null;
        }
        if (!MatchScoringSupport.languageCompatible(sender.getLanguage(), cand.getLanguage())) {
            return null;
        }

        List<Integer> candTags = userTagService.listTagIdsByUserId(cand.getId());
        Double emotion = features != null ? features.emotionScore() : null;
        Double style = features != null ? features.styleScore() : null;
        double score = matchScoringSupport.scoreCandidateWeighted(
                sender,
                cand,
                List.copyOf(senderTagSet),
                candTags,
                senderProtected,
                protectN,
                letterService.countLettersSentByUser(cand.getId()),
                emotion,
                style);
        if (score == Double.NEGATIVE_INFINITY) {
            return null;
        }
        // §7.5 / §2.8：新用户首封信优先匹配高回信意愿用户
        if (senderProtected) {
            long replies = letterService.countRepliesSentByUser(cand.getId());
            long sent = letterService.countLettersSentByUser(cand.getId());
            double replyRate = sent <= 0 ? 0.0 : Math.min(1.0, (double) replies / (double) sent);
            score += 0.15 * replyRate;
        }
        return score;
    }

    private record ScoredCandidate(long userId, double score) {
    }
}
