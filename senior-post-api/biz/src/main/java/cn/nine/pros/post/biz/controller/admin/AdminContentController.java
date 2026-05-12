package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.model.domain.PostcardCommentDomain;
import cn.nine.pros.post.biz.model.domain.PostcardDomain;
import cn.nine.pros.post.biz.model.mapstruct.PostcardCommentMapstruct;
import cn.nine.pros.post.biz.model.mapstruct.PostcardMapstruct;
import cn.nine.pros.post.biz.service.base.OssDisplayUrlService;
import cn.nine.pros.post.biz.service.base.PostcardCommentService;
import cn.nine.pros.post.biz.service.base.PostcardService;
import cn.nine.pros.post.client.api.admin.AdminContentApi;
import cn.nine.pros.post.client.model.db.PostcardCommentDTO;
import cn.nine.pros.post.client.model.db.PostcardDTO;
import cn.nine.pros.post.client.model.input.admin.CommentQueryInDto;
import cn.nine.pros.post.client.model.input.admin.ContentRejectInDto;
import cn.nine.pros.post.client.model.input.admin.PostcardQueryInDto;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@RestController
@RequiredArgsConstructor
public class AdminContentController implements AdminContentApi {

    private final PostcardService postcardService;
    private final PostcardMapstruct postcardMapstruct;
    private final PostcardCommentService postcardCommentService;
    private final PostcardCommentMapstruct postcardCommentMapstruct;
    private final OssDisplayUrlService ossDisplayUrlService;
    private final AppMessages appMessages;

    @Override
    public PostcardDTO getPostcard(Long id) {
        PostcardDomain row = postcardService.getById(id);
        if (row == null || row.isDelFlag()) {
            throw new BadRequestException(appMessages.get("admin.error.content.postcardNotFound"));
        }
        PostcardDTO dto = postcardMapstruct.toDTO(row);
        applyStaffPostcardImages(dto);
        return dto;
    }

    @Override
    public PageData<PostcardDTO> pagingPostcards(PostcardQueryInDto body) {
        PageQuery pageQuery = AdminPageHelper.normalize(body.getPage());
        LambdaQueryWrapper<PostcardDomain> qw = new LambdaQueryWrapper<PostcardDomain>()
                .eq(PostcardDomain::isDelFlag, false)
                .orderByDesc(PostcardDomain::getCreatedAt);
        if (body.getReviewStatus() != null) {
            qw.eq(PostcardDomain::getReviewStatus, body.getReviewStatus());
        }
        if (body.getUserId() != null) {
            qw.eq(PostcardDomain::getUserId, body.getUserId());
        }
        Page<PostcardDomain> p = postcardService.page(AdminPageHelper.mpPage(pageQuery), qw);
        List<PostcardDTO> list = p.getRecords().stream().map(postcardMapstruct::toDTO).collect(Collectors.toList());
        for (PostcardDTO dto : list) {
            applyStaffPostcardImages(dto);
        }
        return AdminPageHelper.pageData(pageQuery, p, list);
    }

    @Override
    public PageData<PostcardCommentDTO> pagingComments(CommentQueryInDto body) {
        PageQuery pageQuery = AdminPageHelper.normalize(body.getPage());
        LambdaQueryWrapper<PostcardCommentDomain> qw = new LambdaQueryWrapper<PostcardCommentDomain>()
                .eq(PostcardCommentDomain::isDelFlag, false)
                .orderByDesc(PostcardCommentDomain::getCreatedAt);
        if (body.getReviewStatus() != null) {
            qw.eq(PostcardCommentDomain::getReviewStatus, body.getReviewStatus());
        }
        if (body.getPostcardId() != null) {
            qw.eq(PostcardCommentDomain::getPostcardId, body.getPostcardId());
        }
        Page<PostcardCommentDomain> p = postcardCommentService.page(AdminPageHelper.mpPage(pageQuery), qw);
        List<PostcardCommentDTO> list = p.getRecords().stream().map(postcardCommentMapstruct::toDTO).collect(Collectors.toList());
        return AdminPageHelper.pageData(pageQuery, p, list);
    }

    @Override
    public void approvePostcard(Long id) {
        postcardService.update(new LambdaUpdateWrapper<PostcardDomain>()
                .eq(PostcardDomain::getId, id)
                .set(PostcardDomain::getReviewStatus, 1)
                .set(PostcardDomain::getStatus, 1));
    }

    @Override
    public void rejectPostcard(Long id, ContentRejectInDto body) {
        postcardService.update(new LambdaUpdateWrapper<PostcardDomain>()
                .eq(PostcardDomain::getId, id)
                .set(PostcardDomain::getReviewStatus, 2)
                .set(PostcardDomain::getStatus, 2));
    }

    @Override
    public void approveComment(Long id) {
        postcardCommentService.update(new LambdaUpdateWrapper<PostcardCommentDomain>()
                .eq(PostcardCommentDomain::getId, id)
                .set(PostcardCommentDomain::getReviewStatus, 1)
                .set(PostcardCommentDomain::getStatus, 1));
    }

    @Override
    public void rejectComment(Long id, ContentRejectInDto body) {
        postcardCommentService.update(new LambdaUpdateWrapper<PostcardCommentDomain>()
                .eq(PostcardCommentDomain::getId, id)
                .set(PostcardCommentDomain::getReviewStatus, 2)
                .set(PostcardCommentDomain::getStatus, 2));
    }

    private void applyStaffPostcardImages(PostcardDTO dto) {
        if (dto == null) {
            return;
        }
        Set<String> refs = new LinkedHashSet<>();
        if (dto.getImages() != null) {
            for (String u : dto.getImages()) {
                if (StringUtils.hasText(u)) {
                    refs.add(u.trim());
                }
            }
        }
        if (StringUtils.hasText(dto.getMainImageUrl())) {
            refs.add(dto.getMainImageUrl().trim());
        }
        if (refs.isEmpty()) {
            return;
        }
        Map<String, String> m = ossDisplayUrlService.signForStaffBatch(refs);
        if (StringUtils.hasText(dto.getMainImageUrl())) {
            String k = dto.getMainImageUrl().trim();
            dto.setMainImageUrl(m.getOrDefault(k, dto.getMainImageUrl()));
        }
        if (dto.getImages() != null) {
            List<String> next = new ArrayList<>();
            for (String u : dto.getImages()) {
                if (!StringUtils.hasText(u)) {
                    next.add(u);
                    continue;
                }
                String t = u.trim();
                next.add(m.getOrDefault(t, u));
            }
            dto.setImages(next);
        }
    }
}
