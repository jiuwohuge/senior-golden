package cn.nine.pros.post.biz.service.biz.impl;

import cn.nine.pros.post.biz.model.domain.DailyRecommendationDomain;
import cn.nine.pros.post.biz.model.domain.UserDomain;
import cn.nine.pros.post.biz.service.base.ConfigService;
import cn.nine.pros.post.biz.service.base.DailyRecommendationService;
import cn.nine.pros.post.biz.service.base.FriendshipService;
import cn.nine.pros.post.biz.service.base.LetterService;
import cn.nine.pros.post.biz.service.base.OssDisplayUrlService;
import cn.nine.pros.post.biz.service.base.PenpalRequestService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.biz.service.base.UserTagService;
import cn.nine.pros.post.biz.service.biz.AppBlacklistService;
import cn.nine.pros.post.biz.service.biz.AppRecommendBizService;
import cn.nine.pros.post.biz.service.biz.support.MatchScoringSupport;
import cn.nine.pros.post.biz.service.biz.support.UserAvatarAuditSupport;
import cn.nine.pros.post.biz.service.biz.support.UserInterestAssembler;
import cn.nine.pros.post.client.model.db.UserDTO;
import cn.nine.pros.post.client.model.out.DirectoryUserItemVO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Slf4j
@Service
@RequiredArgsConstructor
public class AppRecommendBizServiceImpl implements AppRecommendBizService {

    private static final String KEY_DAILY_COUNT = "recommend.daily_count";
    private static final String KEY_PROTECT = "match.new_user_protect_count";
    private static final String KEY_CANDIDATES = "match.candidate_pool_size";
    private static final int DEFAULT_DAILY = 5;

    private final DailyRecommendationService dailyRecommendationService;
    private final UserService userService;
    private final UserTagService userTagService;
    private final LetterService letterService;
    private final FriendshipService friendshipService;
    private final PenpalRequestService penpalRequestService;
    private final AppBlacklistService appBlacklistService;
    private final ConfigService configService;
    private final OssDisplayUrlService ossDisplayUrlService;
    private final UserInterestAssembler userInterestAssembler;
    private final cn.nine.pros.post.biz.i18n.AppMessages appMessages;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public List<DirectoryUserItemVO> listTodayRecommendations(long viewerUserId) {
        LocalDate today = LocalDate.now();
        if (!dailyRecommendationService.existsForUserOnDate(viewerUserId, today)) {
            generateForDate(viewerUserId, today);
        }
        List<DailyRecommendationDomain> rows = dailyRecommendationService.listForUserOnDate(viewerUserId, today);
        List<DirectoryUserItemVO> out = new ArrayList<>();
        for (DailyRecommendationDomain row : rows) {
            if (row.getTargetUserId() == null) {
                continue;
            }
            UserDomain u = userService.getById(row.getTargetUserId());
            if (u == null || u.isDelFlag()) {
                continue;
            }
            DirectoryUserItemVO vo = toVo(viewerUserId, u);
            if (StringUtils.hasText(row.getReasonKey())) {
                vo.setRecommendReason(appMessages.get(row.getReasonKey()));
            }
            out.add(vo);
        }
        return out;
    }

    private void generateForDate(long viewerUserId, LocalDate date) {
        UserDTO viewer = userService.findById(viewerUserId);
        if (viewer == null) {
            return;
        }
        int dailyCount = Math.max(3, Math.min(5, configService.getInt(KEY_DAILY_COUNT, DEFAULT_DAILY)));
        int candidateLimit = Math.max(20, configService.getInt(KEY_CANDIDATES, 200));
        int protectN = Math.max(0, configService.getInt(KEY_PROTECT, 3));
        List<Integer> viewerTags = userTagService.listTagIdsByUserId(viewerUserId);
        boolean viewerProtected = letterService.countLettersSentByUser(viewerUserId) <= protectN;

        List<UserDomain> candidates = userService.listActiveAppUsersExcluding(viewerUserId, candidateLimit);
        List<ScoredCandidate> scored = new ArrayList<>();
        for (UserDomain cand : candidates) {
            if (!isEligible(viewerUserId, cand.getId())) {
                continue;
            }
            if (!MatchScoringSupport.languageCompatible(viewer.getLanguage(), cand.getLanguage())) {
                continue;
            }
            List<Integer> candTags = userTagService.listTagIdsByUserId(cand.getId());
            double score = MatchScoringSupport.scoreCandidate(
                    viewer,
                    cand,
                    viewerTags,
                    candTags,
                    viewerProtected,
                    protectN,
                    letterService.countLettersSentByUser(cand.getId()));
            if (score == Double.NEGATIVE_INFINITY) {
                continue;
            }
            String reasonKey = MatchScoringSupport.resolveReasonKey(viewer, cand, viewerTags, candTags);
            scored.add(new ScoredCandidate(cand.getId(), score, reasonKey));
        }
        scored.sort(Comparator.comparingDouble(ScoredCandidate::score).reversed());
        int n = 0;
        for (ScoredCandidate sc : scored) {
            if (n >= dailyCount) {
                break;
            }
            DailyRecommendationDomain row = new DailyRecommendationDomain();
            row.setUserId(viewerUserId);
            row.setTargetUserId(sc.userId());
            row.setRecommendDate(date);
            row.setScore(sc.score());
            row.setReasonKey(sc.reasonKey());
            row.initAudit(viewerUserId);
            dailyRecommendationService.save(row);
            n++;
        }
        if (n > 0) {
            log.info("daily recommendations generated, userId={}, date={}, count={}", viewerUserId, date, n);
        }
    }

    private boolean isEligible(long viewerUserId, Long candId) {
        if (candId == null) {
            return false;
        }
        if (friendshipService.areActiveFriends(viewerUserId, candId)) {
            return false;
        }
        if (penpalRequestService.existsPendingBetween(viewerUserId, candId)) {
            return false;
        }
        return !appBlacklistService.areMutuallyBlocked(viewerUserId, candId);
    }

    private DirectoryUserItemVO toVo(long viewerUserId, UserDomain u) {
        String av = UserAvatarAuditSupport.publicStoredRef(u);
        if (StringUtils.hasText(av)) {
            av = ossDisplayUrlService.signAvatarForViewer(viewerUserId, av.trim());
        }
        UserInterestAssembler.Payload interests = userInterestAssembler.loadForUser(u.getId());
        boolean postalFriend = u.getId() != null && friendshipService.areActiveFriends(viewerUserId, u.getId());
        return DirectoryUserItemVO.builder()
                .id(u.getId())
                .nickname(u.getNickname())
                .gender(u.getGender())
                .countryCode(u.getCountryCode())
                .bio(u.getBio())
                .birthYear(u.getBirthYear())
                .avatarUrl(av)
                .isVip(Boolean.TRUE.equals(u.getIsVip()))
                .postalFriend(postalFriend)
                .interestTagIds(interests.ids())
                .interestTagNames(interests.names())
                .build();
    }

    private record ScoredCandidate(long userId, double score, String reasonKey) {
    }
}
