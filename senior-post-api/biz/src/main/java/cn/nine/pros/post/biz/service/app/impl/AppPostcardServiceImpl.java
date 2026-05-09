package cn.nine.pros.post.biz.service.app.impl;

import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.controller.app.AppPageHelper;
import cn.nine.pros.post.biz.model.domain.PostcardCommentDomain;
import cn.nine.pros.post.biz.model.domain.PostcardDomain;
import cn.nine.pros.post.biz.service.app.AppBlacklistService;
import cn.nine.pros.post.biz.service.app.AppPostcardService;
import cn.nine.pros.post.biz.service.base.OssDisplayUrlService;
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
import cn.nine.pros.post.client.model.out.PostcardDetailVO;
import cn.nine.pros.post.client.model.out.PostcardWallItemVO;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
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
    private final UserService userService;
    private final SensitiveWordService sensitiveWordService;
    private final OssDisplayUrlService ossDisplayUrlService;
    private final StampGrantService stampGrantService;
    private final AppBlacklistService appBlacklistService;

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
                        + "OR (bl.user_id = bu_postcard.user_id AND bl.blocked_user_id = {0})))", userId)
                .orderByDesc(PostcardDomain::getPublishedAt);
        Page<PostcardDomain> p = postcardService.page(AppPageHelper.mpPage(pq), qw);
        Map<Long, UserDTO> authorMap = loadAuthors(p.getRecords());
        List<PostcardWallItemVO> records = new ArrayList<>();
        for (PostcardDomain row : p.getRecords()) {
            int cc = countVisibleComments(row.getId());
            records.add(toWallItem(row, authorMap.get(row.getUserId()), cc, false));
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
            records.add(toWallItem(row, authorMap.get(row.getUserId()), cc, true));
        }
        ossDisplayUrlService.applyPostcardWall(userId, records);
        return AppPageHelper.pageData(pq, p, records);
    }

    @Override
    public PostcardDetailVO getDetail(long viewerUserId, Long postcardId) {
        PostcardDomain p = postcardService.getById(postcardId);
        if (p == null || p.isDelFlag()) {
            throw new BadRequestException("明信片不存在");
        }
        if (isApprovedPublic(p)) {
            if (appBlacklistService.areMutuallyBlocked(viewerUserId, p.getUserId())) {
                throw new BadRequestException("明信片不存在");
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
        throw new BadRequestException("明信片不存在");
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public PostcardDetailVO create(long userId, AppPostcardCreateInDto body) {
        String content = body.getContent() == null ? "" : body.getContent().trim();
        if (!StringUtils.hasText(content)) {
            throw new BadRequestException("正文不能为空");
        }
        if (content.length() > 2000) {
            throw new BadRequestException("正文过长");
        }
        sensitiveWordService.assertPlainTextAllowed(content);
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
        PostcardDomain fresh = postcardService.getById(d.getId());
        UserDTO author = userService.findById(userId);
        PostcardDetailVO vo = toDetail(fresh, author, 0, userId);
        ossDisplayUrlService.applyPostcardDetail(userId, vo);
        return vo;
    }

    @Override
    @SuppressWarnings("unused")
    public PageData<PostcardCommentItemVO> commentsPage(
            long viewerUserId, Long postcardId, AppPostcardCommentPageInDto body) {
        requireApprovedPostcardForComments(postcardId);
        PageQuery pq = AppPageHelper.normalize(body == null ? null : body.getPage());
        LambdaQueryWrapper<PostcardCommentDomain> qw = new LambdaQueryWrapper<PostcardCommentDomain>()
                .eq(PostcardCommentDomain::getPostcardId, postcardId)
                .eq(PostcardCommentDomain::isDelFlag, false)
                .eq(PostcardCommentDomain::getStatus, 1)
                // 0=待审 1=通过：App 展示正文；2=驳回：不展示（与 DB 注释一致）
                .apply("(review_status IS DISTINCT FROM 2)")
                .orderByDesc(PostcardCommentDomain::getCreatedAt);
        Page<PostcardCommentDomain> p = postcardCommentService.page(AppPageHelper.mpPage(pq), qw);
        Map<Long, UserDTO> authors = loadAuthorsFromComments(p.getRecords());
        List<PostcardCommentItemVO> list = p.getRecords().stream()
                .map(c -> toCommentItem(c, authors.get(c.getUserId())))
                .collect(Collectors.toList());
        for (PostcardCommentItemVO c : list) {
            if (c.getAuthor() != null) {
                ossDisplayUrlService.applyAuthor(viewerUserId, c.getAuthor());
            }
        }
        return AppPageHelper.pageData(pq, p, list);
    }

    @Override
    public PostcardCommentItemVO createComment(long userId, Long postcardId, AppPostcardCommentCreateInDto body) {
        requireApprovedPostcardForComments(postcardId);
        String text = body.getContent() == null ? "" : body.getContent().trim();
        if (!StringUtils.hasText(text)) {
            throw new BadRequestException("评论不能为空");
        }
        if (text.length() > 1000) {
            throw new BadRequestException("评论过长");
        }
        sensitiveWordService.assertPlainTextAllowed(text);
        PostcardCommentDomain c = new PostcardCommentDomain();
        c.setPostcardId(postcardId);
        c.setUserId(userId);
        c.setContent(text);
        c.setStatus(1);
        c.setReviewStatus(0);
        c.initAudit(userId);
        postcardCommentService.save(c);
        PostcardCommentDomain fresh = postcardCommentService.getById(c.getId());
        UserDTO author = userService.findById(userId);
        PostcardCommentItemVO vo = toCommentItem(fresh, author);
        if (vo.getAuthor() != null) {
            ossDisplayUrlService.applyAuthor(userId, vo.getAuthor());
        }
        return vo;
    }

    private PostcardDomain requireApprovedPostcardForComments(Long postcardId) {
        PostcardDomain pc = postcardService.getById(postcardId);
        if (pc == null || pc.isDelFlag()) {
            throw new BadRequestException("明信片不存在");
        }
        if (!isApprovedPublic(pc)) {
            throw new BadRequestException("明信片未公开，暂不可评论");
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
        Set<Long> ids = rows.stream().map(PostcardCommentDomain::getUserId).filter(Objects::nonNull).collect(Collectors.toSet());
        Map<Long, UserDTO> map = new HashMap<>();
        for (Long id : ids) {
            UserDTO u = userService.findById(id);
            if (u != null) {
                map.put(id, u);
            }
        }
        return map;
    }

    private static PostcardWallItemVO toWallItem(PostcardDomain row, UserDTO author, int commentCount, boolean includeAuditFields) {
        List<String> imgs = normalizeImageUrls(row);
        String first = imgs.isEmpty() ? null : imgs.get(0);
        PostcardWallItemVO.PostcardWallItemVOBuilder b = PostcardWallItemVO.builder()
                .id(row.getId())
                .content(row.getContent())
                .imageUrl(first)
                .imageUrls(imgs.isEmpty() ? null : imgs)
                .publishedAt(toLocalDateTime(row.getPublishedAt()))
                .commentCount(commentCount)
                .author(toAuthor(author));
        if (includeAuditFields) {
            b.reviewStatus(intVal(row.getReviewStatus()))
                    .postStatus(intVal(row.getStatus()));
        }
        return b.build();
    }

    private PostcardDetailVO toDetail(PostcardDomain row, UserDTO author, int commentCount, long viewerUserId) {
        List<String> imgs = normalizeImageUrls(row);
        String first = imgs.isEmpty() ? null : imgs.get(0);
        return PostcardDetailVO.builder()
                .id(row.getId())
                .content(row.getContent())
                .imageUrl(first)
                .imageUrls(imgs.isEmpty() ? null : imgs)
                .publishedAt(toLocalDateTime(row.getPublishedAt()))
                .commentCount(commentCount)
                .author(toAuthor(author))
                .reviewStatus(intVal(row.getReviewStatus()))
                .owner(Objects.equals(viewerUserId, row.getUserId()))
                .build();
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

    private static PostcardCommentItemVO toCommentItem(PostcardCommentDomain c, UserDTO author) {
        return PostcardCommentItemVO.builder()
                .id(c.getId())
                .content(c.getContent())
                .createdAt(toLocalDateTime(c.getCreatedAt()))
                .author(toAuthor(author))
                .build();
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
                .countryCode(cc)
                .countryName(cc)
                .avatarUrl(u.getAvatarUrl())
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
