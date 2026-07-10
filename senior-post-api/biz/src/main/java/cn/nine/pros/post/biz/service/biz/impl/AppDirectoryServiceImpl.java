package cn.nine.pros.post.biz.service.biz.impl;

import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.controller.app.AppPageHelper;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.model.domain.FriendshipDomain;
import cn.nine.pros.post.biz.model.domain.TagDomain;
import cn.nine.pros.post.biz.model.domain.UserDomain;
import cn.nine.pros.post.biz.service.biz.AppBlacklistService;
import cn.nine.pros.post.biz.service.biz.AppDirectoryService;
import cn.nine.pros.post.biz.service.biz.AppRecommendBizService;
import cn.nine.pros.post.biz.service.biz.AppRelationBizService;
import cn.nine.pros.post.biz.service.biz.support.UserAvatarAuditSupport;
import cn.nine.pros.post.biz.service.biz.support.UserInterestAssembler;
import cn.nine.pros.post.biz.service.base.FriendshipService;
import cn.nine.pros.post.biz.service.base.LetterService;
import cn.nine.pros.post.biz.service.base.OssDisplayUrlService;
import cn.nine.pros.post.biz.service.base.TagService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.client.model.input.app.AppDirectoryPageInDto;
import cn.nine.pros.post.client.model.out.DirectoryUserItemVO;
import cn.nine.pros.post.client.model.out.InterestTagOptionVO;
import cn.nine.pros.post.client.model.out.PenpalListItemVO;
import cn.nine.pros.post.client.model.out.RelationSnapshotVO;
import cn.nine.pros.post.client.common.enums.RelationDisplayState;
import cn.nine.pros.post.client.model.db.UserDTO;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AppDirectoryServiceImpl implements AppDirectoryService {

    private static final int USER_STATUS_NORMAL = 1;

    private final UserService userService;
    private final TagService tagService;
    private final OssDisplayUrlService ossDisplayUrlService;
    private final UserInterestAssembler userInterestAssembler;
    private final AppBlacklistService appBlacklistService;
    private final FriendshipService friendshipService;
    private final LetterService letterService;
    private final AppRelationBizService appRelationBizService;
    private final AppRecommendBizService appRecommendBizService;
    private final AppMessages appMessages;

    @Override
    public PageData<DirectoryUserItemVO> pageUsers(long viewerUserId, AppDirectoryPageInDto body) {
        PageQuery pq = AppPageHelper.normalize(body == null ? null : body.getPage());
        Page<UserDomain> p = userService.pageDirectory(viewerUserId, body, pq);
        List<DirectoryUserItemVO> records = new ArrayList<>();
        for (UserDomain u : p.getRecords()) {
            records.add(toVo(viewerUserId, u));
        }
        return AppPageHelper.pageData(pq, p, records);
    }

    @Override
    public DirectoryUserItemVO getDirectoryUser(long viewerUserId, long targetUserId) {
        UserDomain u = userService.getById(targetUserId);
        if (u == null || u.isDelFlag()) {
            throw new BadRequestException(appMessages.get("app.error.user.notFound"));
        }
        if (!isDirectoryListableUser(u)) {
            throw new BadRequestException(appMessages.get("app.error.user.hidden"));
        }
        if (appBlacklistService.areMutuallyBlocked(viewerUserId, targetUserId)) {
            throw new BadRequestException(appMessages.get("app.error.user.hidden"));
        }
        return toVo(viewerUserId, u);
    }

    @Override
    public List<String> listInterestTagNames(String langCode) {
        String lang = StringUtils.hasText(langCode) ? langCode.trim().toLowerCase() : "en";
        List<String> primary = loadTagNamesForLang(lang);
        if (!primary.isEmpty()) {
            return primary;
        }
        if (!"en".equals(lang)) {
            return loadTagNamesForLang("en");
        }
        return List.of();
    }

    @Override
    public List<InterestTagOptionVO> listInterestTagOptions(String langCode) {
        String lang = StringUtils.hasText(langCode) ? langCode.trim().toLowerCase() : "en";
        List<InterestTagOptionVO> primary = loadTagOptionsForLang(lang);
        if (!primary.isEmpty()) {
            return primary;
        }
        if (!"en".equals(lang)) {
            return loadTagOptionsForLang("en");
        }
        return List.of();
    }

    @Override
    public List<DirectoryUserItemVO> listTodayRecommendations(long viewerUserId) {
        return appRecommendBizService.listTodayRecommendations(viewerUserId);
    }

    @Override
    public List<PenpalListItemVO> listPenpals(long viewerUserId) {
        List<FriendshipDomain> rows = friendshipService.listActiveFriendshipsForUser(viewerUserId);
        List<PenpalListItemVO> out = new ArrayList<>();
        for (FriendshipDomain f : rows) {
            long low = f.getUserLow() != null ? f.getUserLow() : 0L;
            long high = f.getUserHigh() != null ? f.getUserHigh() : 0L;
            long peerId = low == viewerUserId ? high : low;
            if (peerId <= 0) {
                continue;
            }
            UserDTO peer = userService.findById(peerId);
            if (peer == null) {
                continue;
            }
            String avatar = UserAvatarAuditSupport.publicStoredRef(peer);
            if (StringUtils.hasText(avatar)) {
                avatar = ossDisplayUrlService.signAvatarForViewer(viewerUserId, avatar.trim());
            }
            LocalDateTime since = f.getUpdatedAt() != null ? f.getUpdatedAt() : f.getCreatedAt();
            int penpalDays = since != null
                    ? (int) ChronoUnit.DAYS.between(since.toLocalDate(), LocalDate.now())
                    : 0;
            int letterCount = (int) letterService.countExchangeBetween(viewerUserId, peerId);
            out.add(PenpalListItemVO.builder()
                    .peerUserId(peerId)
                    .nickname(peer.getNickname())
                    .avatarUrl(avatar)
                    .countryCode(peer.getCountryCode())
                    .letterCount(letterCount)
                    .penpalDays(Math.max(0, penpalDays))
                    .penpalSince(since)
                    .build());
        }
        return out;
    }

    private List<InterestTagOptionVO> loadTagOptionsForLang(String lang) {
        return tagService.listActiveByLang(lang).stream()
                .filter(t -> t.getId() != null && StringUtils.hasText(t.getTagName()))
                .map(
                        t -> InterestTagOptionVO.builder()
                                .id(t.getId())
                                .tagName(t.getTagName().trim())
                                .langCode(lang)
                                .build())
                .collect(Collectors.toList());
    }

    private List<String> loadTagNamesForLang(String lang) {
        return tagService.listActiveByLang(lang).stream()
                .map(TagDomain::getTagName)
                .filter(StringUtils::hasText)
                .map(String::trim)
                .distinct()
                .collect(Collectors.toList());
    }

    private DirectoryUserItemVO toVo(long viewerUserId, UserDomain u) {
        String av = UserAvatarAuditSupport.publicStoredRef(u);
        if (StringUtils.hasText(av)) {
            av = ossDisplayUrlService.signAvatarForViewer(viewerUserId, av.trim());
        }
        UserInterestAssembler.Payload interests = userInterestAssembler.loadForUser(u.getId());
        boolean postalFriend = u.getId() != null && friendshipService.areActiveFriends(viewerUserId, u.getId());
        RelationSnapshotVO relation = u.getId() != null
                ? appRelationBizService.resolveRelationSnapshot(viewerUserId, u.getId())
                : null;
        Integer displayState = relation != null
                ? relation.getDisplayState()
                : (postalFriend ? RelationDisplayState.PENPAL.getCode() : RelationDisplayState.STRANGER.getCode());
        Integer letterCount = relation != null ? relation.getLetterCount() : 0;
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
                .relationDisplayState(displayState)
                .letterCount(letterCount)
                .interestTagIds(interests.ids())
                .interestTagNames(interests.names())
                .build();
    }

    private boolean isDirectoryListableUser(UserDomain u) {
        if (userStatus(u.getStatus()) != USER_STATUS_NORMAL) {
            return false;
        }
        Integer sr = u.getStaffRole();
        return sr != null && sr == 0;
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
}
