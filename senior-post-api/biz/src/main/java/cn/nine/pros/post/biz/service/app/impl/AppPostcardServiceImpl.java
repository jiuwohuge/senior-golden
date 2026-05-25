package cn.nine.pros.post.biz.service.app.impl;

import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.controller.app.AppPageHelper;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.model.domain.PostcardCommentDomain;
import cn.nine.pros.post.biz.model.domain.PostcardCommentLikeDomain;
import cn.nine.pros.post.biz.model.domain.PostcardDomain;
import cn.nine.pros.post.biz.moderation.PostcardCreatedEvent;
import cn.nine.pros.post.biz.service.app.AppBlacklistService;
import cn.nine.pros.post.biz.service.app.support.UserAvatarAuditSupport;
import cn.nine.pros.post.biz.service.app.AppPostcardService;
import cn.nine.pros.post.biz.service.base.FriendshipService;
import cn.nine.pros.post.biz.service.base.OssDisplayUrlService;
import cn.nine.pros.post.biz.service.base.PostcardCommentLikeService;
import cn.nine.pros.post.biz.service.base.PostcardCommentService;
import cn.nine.pros.post.biz.service.base.PostcardService;
import cn.nine.pros.post.biz.service.base.SensitiveWordService;
import cn.nine.pros.post.biz.service.base.StampGrantService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.client.model.db.UserDTO;
import cn.nine.pros.post.client.model.input.app.AppPostcardCommentCreateInDto;
import cn.nine.pros.post.client.model.input.app.AppPostcardCommentPageInDto;
import cn.nine.pros.post.client.model.input.app.AppPostcardCreateInDto;
import cn.nine.pros.post.client.model.input.app.AppPostcardPageInDto;
import cn.nine.pros.post.client.model.out.PostcardAuthorVO;
import cn.nine.pros.post.client.model.out.PostcardCommentItemVO;
import cn.nine.pros.post.client.model.out.PostcardCommentLikeVO;
import cn.nine.pros.post.client.model.out.PostcardDetailVO;
import cn.nine.pros.post.client.model.out.PostcardWallItemVO;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AppPostcardServiceImpl implements AppPostcardService {

    private final PostcardService postcardService;
    private final PostcardCommentService postcardCommentService;
    private final PostcardCommentLikeService postcardCommentLikeService;
    private final UserService userService;
    private final SensitiveWordService sensitiveWordService;
    private final OssDisplayUrlService ossDisplayUrlService;
    private final StampGrantService stampGrantService;
    private final AppBlacklistService appBlacklistService;
    private final FriendshipService friendshipService;
    private final ApplicationEventPublisher applicationEventPublisher;
    private final AppMessages appMessages;

    @Override
    @SuppressWarnings("unused")
    public PageData<PostcardWallItemVO> wallPage(long userId, AppPostcardPageInDto body) {
        PageQuery pq = AppPageHelper.normalize(body == null ? null : body.getPage());
        LambdaQueryWrapper<PostcardDomain> qw = new LambdaQueryWrapper<PostcardDomain>()
                .eq(PostcardDomain::isDelFlag, false)
                .apply("review_status = 1")
                .apply("status = 1")
                .apply("NOT EXISTS (SELECT 1 FROM bu_user_blacklist bl WHERE bl.del_flag = FALSE "
                        + "AND ((bl.user_id = {0} AND bl.blocked_user_id = bu_postcard.user_id) "
                        + "OR (bl.user_id = bu_postcard.user_id AND bl.blocked_user_id = {0})))", userId);
        if (body != null && Boolean.TRUE.equals(body.getConnectionsOnly())) {
            qw.apply(
                    "EXISTS (SELECT 1 FROM bu_friendship f WHERE f.del_flag = FALSE AND f.status = 1 "
                            + "AND ((f.user_low = {0} AND f.user_high = bu_postcard.user_id) "
                            + "OR (f.user_high = {0} AND f.user_low = bu_postcard.user_id)))",
                    userId);
        }
        qw.orderByDesc(PostcardDomain::getPublishedAt);
        Page<PostcardDomain> p = postcardService.page(AppPageHelper.mpPage(pq), qw);
        Map<Long, UserDTO> authorMap = loadAuthors(p.getRecords());
        List<PostcardWallItemVO> records = new ArrayList<>();
        for (PostcardDomain row : p.getRecords()) {
            int cc = countVisibleComments(row.getId());
            records.add(toWallItem(row, authorMap.get(row.getUserId()), cc, false, userId));
        }
        ossDisplayUrlService.applyPostcardWall(userId, records);
        return AppPageHelper.pageData(pq, p, records);
    }

    @Override
    public PageData<PostcardWallItemVO> minePage(long userId, AppPostcardPageInDto body) {
        PageQuery pq = AppPageHelper.normalize(body == null ? null : body.getPage());
        LambdaQueryWrapper<PostcardDomain> qw = new LambdaQueryWrapper<PostcardDomain>()
                .eq(PostcardDomain::isDelFlag, false)
                .eq(PostcardDomain::getUserId, userId)
                .orderByDesc(PostcardDomain::getPublishedAt);
        Page<PostcardDomain> p = postcardService.page(AppPageHelper.mpPage(pq), qw);
        Map<Long, UserDTO> authorMap = loadAuthors(p.getRecords());
        List<PostcardWallItemVO> records = new ArrayList<>();
        for (PostcardDomain row : p.getRecords()) {
            int cc = countVisibleComments(row.getId());
            records.add(toWallItem(row, authorMap.get(row.getUserId()), cc, true, userId));
        }
        ossDisplayUrlService.applyPostcardWall(userId, records);
        return AppPageHelper.pageData(pq, p, records);
    }

    @Override
    public PostcardDetailVO getDetail(long viewerUserId, Long postcardId) {
        PostcardDomain p = postcardService.getById(postcardId);
        if (p == null || p.isDelFlag()) {
            throw new BadRequestException(appMessages.get("app.error.postcard.notFound"));
        }
        if (isApprovedPublic(p)) {
            if (appBlacklistService.areMutuallyBlocked(viewerUserId, p.getUserId())) {
                throw new BadRequestException(appMessages.get("app.error.postcard.notFound"));
            }
            UserDTO author = userService.findById(p.getUserId());
            int cc = countVisibleComments(p.getId());
            PostcardDetailVO vo = toDetail(p, author, cc, viewerUserId);
            ossDisplayUrlService.applyPostcardDetail(viewerUserId, vo);
            return vo;
        }
        if (Objects.equals(viewerUserId, p.getUserId())) {
            UserDTO author = userService.findById(p.getUserId());
            int cc = countVisibleComments(p.getId());
            PostcardDetailVO vo = toDetail(p, author, cc, viewerUserId);
            ossDisplayUrlService.applyPostcardDetail(viewerUserId, vo);
            return vo;
        }
        throw new BadRequestException(appMessages.get("app.error.postcard.notFound"));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public PostcardDetailVO create(long userId, AppPostcardCreateInDto body) {
        String content = body.getContent() == null ? "" : body.getContent().trim();
        if (!StringUtils.hasText(content)) {
            throw new BadRequestException(appMessages.get("app.error.postcard.bodyEmpty"));
        }
        if (content.length() > 2000) {
            throw new BadRequestException(appMessages.get("app.error.postcard.bodyTooLong"));
        }
        List<String> urls = new ArrayList<>();
        if (body.getImageUrls() != null) {
            for (String u : body.getImageUrls()) {
                if (StringUtils.hasText(u) && urls.size() < 9) {
                    urls.add(u.trim());
                }
            }
        }
        PostcardDomain d = new PostcardDomain();
        d.setUserId(userId);
        d.setContent(content);
        d.setStatus(1);
        d.setReviewStatus(0);
        d.setPublishedAt(LocalDateTime.now());
        if (!urls.isEmpty()) {
            d.setImages(new ArrayList<>(urls));
            d.setMainImageUrl(urls.get(0));
        } else {
            d.setImages(null);
            d.setMainImageUrl(null);
        }
        d.initAudit(userId);
        postcardService.save(d);
        stampGrantService.afterPostcardCreated(userId, d.getId());
        applicationEventPublisher.publishEvent(new PostcardCreatedEvent(d.getId()));
        PostcardDomain fresh = postcardService.getById(d.getId());
        UserDTO author = userService.findById(userId);
        PostcardDetailVO vo = toDetail(fresh, author, 0, userId);
        ossDisplayUrlService.applyPostcardDetail(userId, vo);
        return vo;
    }

    @Override
    public PageData<PostcardWallItemVO> userPostcardsPage(
            long viewerUserId, long targetUserId, AppPostcardPageInDto body) {
        if (!Objects.equals(viewerUserId, targetUserId)
                && !friendshipService.areActiveFriends(viewerUserId, targetUserId)) {
            throw new BadRequestException(appMessages.get("app.error.postcard.notFound"));
        }
        if (appBlacklistService.areMutuallyBlocked(viewerUserId, targetUserId)) {
            throw new BadRequestException(appMessages.get("app.error.postcard.notFound"));
        }
        PageQuery pq = AppPageHelper.normalize(body == null ? null : body.getPage());
        LambdaQueryWrapper<PostcardDomain> qw = new LambdaQueryWrapper<PostcardDomain>()
                .eq(PostcardDomain::isDelFlag, false)
                .eq(PostcardDomain::getUserId, targetUserId)
                .apply("review_status = 1")
                .apply("status = 1")
                .orderByDesc(PostcardDomain::getPublishedAt);
        Page<PostcardDomain> p = postcardService.page(AppPageHelper.mpPage(pq), qw);
        Map<Long, UserDTO> authorMap = loadAuthors(p.getRecords());
        List<PostcardWallItemVO> records = new ArrayList<>();
        for (PostcardDomain row : p.getRecords()) {
            int cc = countVisibleComments(row.getId());
            records.add(toWallItem(row, authorMap.get(row.getUserId()), cc, false, viewerUserId));
        }
        ossDisplayUrlService.applyPostcardWall(viewerUserId, records);
        return AppPageHelper.pageData(pq, p, records);
    }

    @Override
    @SuppressWarnings("unused")
    public PageData<PostcardCommentItemVO> commentsPage(
            long viewerUserId, Long postcardId, AppPostcardCommentPageInDto body) {
        requireApprovedPostcardForComments(postcardId);
        PageQuery pq = AppPageHelper.normalize(body == null ? null : body.getPage());
        LambdaQueryWrapper<PostcardCommentDomain> rootQw = visibleCommentQuery(postcardId)
                .isNull(PostcardCommentDomain::getParentId)
                .orderByDesc(PostcardCommentDomain::getCreatedAt);
        Page<PostcardCommentDomain> p = postcardCommentService.page(AppPageHelper.mpPage(pq), rootQw);
        List<PostcardCommentDomain> roots = p.getRecords();
        if (roots.isEmpty()) {
            return AppPageHelper.pageData(pq, p, List.of());
        }
        List<Long> rootIds = roots.stream().map(PostcardCommentDomain::getId).filter(Objects::nonNull).toList();
        List<PostcardCommentDomain> replyRows = postcardCommentService.list(
                visibleCommentQuery(postcardId)
                        .isNotNull(PostcardCommentDomain::getParentId)
                        .in(PostcardCommentDomain::getRootId, rootIds)
                        .orderByAsc(PostcardCommentDomain::getCreatedAt));
        List<PostcardCommentDomain> allRows = new ArrayList<>(roots);
        allRows.addAll(replyRows);
        Map<Long, UserDTO> authors = loadAuthorsFromComments(allRows);
        Set<Long> likedIds = postcardCommentLikeService.findLikedCommentIds(
                viewerUserId,
                allRows.stream().map(PostcardCommentDomain::getId).filter(Objects::nonNull).collect(Collectors.toSet()));
        Map<Long, List<PostcardCommentDomain>> repliesByRoot = replyRows.stream()
                .collect(Collectors.groupingBy(PostcardCommentDomain::getRootId));
        List<PostcardCommentItemVO> list = roots.stream()
                .map(root -> {
                    List<PostcardCommentDomain> reps = repliesByRoot.getOrDefault(root.getId(), List.of());
                    List<PostcardCommentItemVO> replyVos = reps.stream()
                            .map(r -> toCommentItem(r, authors, likedIds, false))
                            .collect(Collectors.toList());
                    PostcardCommentItemVO vo = toCommentItem(root, authors, likedIds, false);
                    vo.setReplies(replyVos);
                    return vo;
                })
                .collect(Collectors.toList());
        applyAuthorOss(viewerUserId, list);
        return AppPageHelper.pageData(pq, p, list);
    }

    @Override
    @Transactional
    public PostcardCommentItemVO createComment(long userId, Long postcardId, AppPostcardCommentCreateInDto body) {
        requireApprovedPostcardForComments(postcardId);
        String text = body.getContent() == null ? "" : body.getContent().trim();
        if (!StringUtils.hasText(text)) {
            throw new BadRequestException(appMessages.get("app.error.comment.empty"));
        }
        if (text.length() > 1000) {
            throw new BadRequestException(appMessages.get("app.error.comment.tooLong"));
        }
        sensitiveWordService.assertPlainTextAllowed(text);
        PostcardCommentDomain c = new PostcardCommentDomain();
        c.setPostcardId(postcardId);
        c.setUserId(userId);
        c.setContent(text);
        c.setStatus(1);
        c.setReviewStatus(0);
        c.setLikeCount(0);
        Long parentId = body.getParentCommentId();
        if (parentId != null) {
            PostcardCommentDomain parent = requireParentComment(postcardId, parentId);
            c.setParentId(parent.getId());
            Long rootId = parent.getRootId() != null ? parent.getRootId() : parent.getId();
            c.setRootId(rootId);
            c.setReplyToUserId(parent.getUserId());
        }
        c.initAudit(userId);
        postcardCommentService.save(c);
        if (parentId == null) {
            c.setRootId(c.getId());
            postcardCommentService.updateById(c);
        }
        PostcardCommentDomain fresh = postcardCommentService.getById(c.getId());
        Map<Long, UserDTO> authors = loadAuthorsFromComments(List.of(fresh));
        if (fresh.getReplyToUserId() != null && !authors.containsKey(fresh.getReplyToUserId())) {
            UserDTO replyTo = userService.findById(fresh.getReplyToUserId());
            if (replyTo != null) {
                authors.put(replyTo.getId(), replyTo);
            }
        }
        PostcardCommentItemVO vo = toCommentItem(fresh, authors, Set.of(), false);
        applyAuthorOss(userId, List.of(vo));
        return vo;
    }

    @Override
    @Transactional
    public PostcardCommentLikeVO toggleCommentLike(long userId, Long postcardId, Long commentId) {
        requireApprovedPostcardForComments(postcardId);
        PostcardCommentDomain comment = requireVisibleComment(postcardId, commentId);
        PostcardCommentLikeDomain existing = postcardCommentLikeService.getOne(
                new LambdaQueryWrapper<PostcardCommentLikeDomain>()
                        .eq(PostcardCommentLikeDomain::getCommentId, commentId)
                        .eq(PostcardCommentLikeDomain::getUserId, userId)
                        .eq(PostcardCommentLikeDomain::isDelFlag, false)
                        .last("LIMIT 1"));
        int likeCount = comment.getLikeCount() == null ? 0 : comment.getLikeCount();
        boolean liked;
        if (existing != null) {
            existing.setDelFlag(true);
            existing.setUpdatedAt(LocalDateTime.now());
            existing.setUpdatedBy(userId);
            postcardCommentLikeService.updateById(existing);
            likeCount = Math.max(0, likeCount - 1);
            liked = false;
        } else {
            PostcardCommentLikeDomain like = new PostcardCommentLikeDomain();
            like.setCommentId(commentId);
            like.setUserId(userId);
            like.initAudit(userId);
            postcardCommentLikeService.save(like);
            likeCount = likeCount + 1;
            liked = true;
        }
        postcardCommentService.update(new LambdaUpdateWrapper<PostcardCommentDomain>()
                .eq(PostcardCommentDomain::getId, commentId)
                .set(PostcardCommentDomain::getLikeCount, likeCount));
        return PostcardCommentLikeVO.builder()
                .commentId(commentId)
                .likeCount(likeCount)
                .likedByMe(liked)
                .build();
    }

    private PostcardDomain requireApprovedPostcardForComments(Long postcardId) {
        PostcardDomain pc = postcardService.getById(postcardId);
        if (pc == null || pc.isDelFlag()) {
            throw new BadRequestException(appMessages.get("app.error.postcard.notFound"));
        }
        if (!isApprovedPublic(pc)) {
            throw new BadRequestException(appMessages.get("app.error.postcard.notPublicComment"));
        }
        return pc;
    }

    private static boolean isApprovedPublic(PostcardDomain p) {
        return intVal(p.getReviewStatus()) == 1 && intVal(p.getStatus()) == 1;
    }

    private static int intVal(Object o) {
        if (o == null) {
            return 0;
        }
        if (o instanceof Number n) {
            return n.intValue();
        }
        return 0;
    }

    /** 墙/详情评论数：与 commentsPage 列表可见范围一致（非驳回、未删）。 */
    private int countVisibleComments(Long postcardId) {
        return (int) postcardCommentService.count(new LambdaQueryWrapper<PostcardCommentDomain>()
                .eq(PostcardCommentDomain::getPostcardId, postcardId)
                .eq(PostcardCommentDomain::isDelFlag, false)
                .eq(PostcardCommentDomain::getStatus, 1)
                .apply("(review_status IS DISTINCT FROM 2)"));
    }

    private Map<Long, UserDTO> loadAuthors(List<PostcardDomain> rows) {
        Set<Long> ids = rows.stream().map(PostcardDomain::getUserId).filter(Objects::nonNull).collect(Collectors.toSet());
        Map<Long, UserDTO> map = new HashMap<>();
        for (Long id : ids) {
            UserDTO u = userService.findById(id);
            if (u != null) {
                map.put(id, u);
            }
        }
        return map;
    }

    private Map<Long, UserDTO> loadAuthorsFromComments(List<PostcardCommentDomain> rows) {
        Set<Long> ids = rows.stream()
                .flatMap(r -> java.util.stream.Stream.of(r.getUserId(), r.getReplyToUserId()))
                .filter(Objects::nonNull)
                .collect(Collectors.toSet());
        Map<Long, UserDTO> map = new HashMap<>();
        for (Long id : ids) {
            UserDTO u = userService.findById(id);
            if (u != null) {
                map.put(id, u);
            }
        }
        return map;
    }

    private static PostcardWallItemVO toWallItem(
            PostcardDomain row, UserDTO author, int commentCount, boolean includeAuditFields, long viewerUserId) {
        List<String> imgs = normalizeImageUrls(row);
        String first = imgs.isEmpty() ? null : imgs.get(0);
        boolean canSendLetter = row.getUserId() != null && !Objects.equals(viewerUserId, row.getUserId());
        PostcardWallItemVO.PostcardWallItemVOBuilder b = PostcardWallItemVO.builder()
                .id(row.getId())
                .content(row.getContent())
                .imageUrl(first)
                .imageUrls(imgs.isEmpty() ? null : imgs)
                .publishedAt(toLocalDateTime(row.getPublishedAt()))
                .commentCount(commentCount)
                .author(toAuthor(author))
                .canSendLetter(canSendLetter);
        if (includeAuditFields) {
            b.reviewStatus(intVal(row.getReviewStatus()))
                    .postStatus(intVal(row.getStatus()));
        }
        return b.build();
    }

    private PostcardDetailVO toDetail(PostcardDomain row, UserDTO author, int commentCount, long viewerUserId) {
        List<String> imgs = normalizeImageUrls(row);
        String first = imgs.isEmpty() ? null : imgs.get(0);
        boolean owner = Objects.equals(viewerUserId, row.getUserId());
        PostcardDetailVO.PostcardDetailVOBuilder b = PostcardDetailVO.builder()
                .id(row.getId())
                .content(row.getContent())
                .imageUrl(first)
                .imageUrls(imgs.isEmpty() ? null : imgs)
                .publishedAt(toLocalDateTime(row.getPublishedAt()))
                .commentCount(commentCount)
                .author(toAuthor(author))
                .reviewStatus(intVal(row.getReviewStatus()))
                .owner(owner)
                .canSendLetter(!owner);
        if (owner && StringUtils.hasText(row.getMachineReviewNote())) {
            b.machineReviewNote(row.getMachineReviewNote().trim());
        }
        return b.build();
    }

    /**
     * 列表/详情统一解析配图：优先 images 列，否则回退 main_image_url。
     */
    private static List<String> normalizeImageUrls(PostcardDomain row) {
        if (row.getImages() != null && !row.getImages().isEmpty()) {
            return row.getImages().stream()
                    .filter(Objects::nonNull)
                    .map(String::trim)
                    .filter(s -> !s.isEmpty())
                    .collect(Collectors.toList());
        }
        if (StringUtils.hasText(row.getMainImageUrl())) {
            return Collections.singletonList(row.getMainImageUrl().trim());
        }
        return List.of();
    }

    private LambdaQueryWrapper<PostcardCommentDomain> visibleCommentQuery(Long postcardId) {
        return new LambdaQueryWrapper<PostcardCommentDomain>()
                .eq(PostcardCommentDomain::getPostcardId, postcardId)
                .eq(PostcardCommentDomain::isDelFlag, false)
                .eq(PostcardCommentDomain::getStatus, 1)
                .apply("(review_status IS DISTINCT FROM 2)");
    }

    private PostcardCommentDomain requireParentComment(Long postcardId, Long parentId) {
        PostcardCommentDomain parent = postcardCommentService.getById(parentId);
        if (parent == null
                || parent.isDelFlag()
                || !Objects.equals(parent.getPostcardId(), postcardId)
                || intVal(parent.getStatus()) != 1
                || intVal(parent.getReviewStatus()) == 2) {
            throw new BadRequestException(appMessages.get("app.error.comment.parentNotFound"));
        }
        return parent;
    }

    private PostcardCommentDomain requireVisibleComment(Long postcardId, Long commentId) {
        PostcardCommentDomain c = postcardCommentService.getById(commentId);
        if (c == null
                || c.isDelFlag()
                || !Objects.equals(c.getPostcardId(), postcardId)
                || intVal(c.getStatus()) != 1
                || intVal(c.getReviewStatus()) == 2) {
            throw new BadRequestException(appMessages.get("app.error.comment.notFound"));
        }
        return c;
    }

    private static PostcardCommentItemVO toCommentItem(
            PostcardCommentDomain c,
            Map<Long, UserDTO> authors,
            Set<Long> likedIds,
            boolean includeRepliesPlaceholder) {
        UserDTO author = authors.get(c.getUserId());
        PostcardAuthorVO replyTo = null;
        if (c.getReplyToUserId() != null) {
            replyTo = toAuthor(authors.get(c.getReplyToUserId()));
        }
        int likes = c.getLikeCount() == null ? 0 : c.getLikeCount();
        return PostcardCommentItemVO.builder()
                .id(c.getId())
                .content(c.getContent())
                .createdAt(toLocalDateTime(c.getCreatedAt()))
                .author(toAuthor(author))
                .replyTo(replyTo)
                .likeCount(likes)
                .likedByMe(likedIds.contains(c.getId()))
                .replies(includeRepliesPlaceholder ? List.of() : null)
                .build();
    }

    private void applyAuthorOss(long viewerUserId, List<PostcardCommentItemVO> roots) {
        for (PostcardCommentItemVO c : roots) {
            if (c.getAuthor() != null) {
                ossDisplayUrlService.applyAuthor(viewerUserId, c.getAuthor());
            }
            if (c.getReplyTo() != null) {
                ossDisplayUrlService.applyAuthor(viewerUserId, c.getReplyTo());
            }
            if (c.getReplies() != null) {
                for (PostcardCommentItemVO r : c.getReplies()) {
                    if (r.getAuthor() != null) {
                        ossDisplayUrlService.applyAuthor(viewerUserId, r.getAuthor());
                    }
                    if (r.getReplyTo() != null) {
                        ossDisplayUrlService.applyAuthor(viewerUserId, r.getReplyTo());
                    }
                }
            }
        }
    }

    private static PostcardAuthorVO toAuthor(UserDTO u) {
        if (u == null) {
            return PostcardAuthorVO.builder()
                    .userId(0L)
                    .nickname("User")
                    .countryCode("")
                    .countryName("")
                    .avatarUrl(null)
                    .build();
        }
        String cc = u.getCountryCode() == null ? "" : u.getCountryCode();
        return PostcardAuthorVO.builder()
                .userId(u.getId())
                .nickname(u.getNickname() == null ? "User" : u.getNickname())
                .gender(u.getGender())
                .countryCode(cc)
                .countryName(cc)
                .avatarUrl(UserAvatarAuditSupport.publicStoredRef(u))
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
