package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.model.domain.PostcardCommentDomain;
import cn.nine.pros.post.biz.model.domain.PostcardDomain;
import cn.nine.pros.post.biz.model.mapstruct.PostcardCommentMapstruct;
import cn.nine.pros.post.biz.model.mapstruct.PostcardMapstruct;
import cn.nine.pros.post.biz.service.base.PostcardCommentService;
import cn.nine.pros.post.biz.service.base.PostcardService;
import cn.nine.pros.post.client.api.admin.AdminContentApi;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.db.PostcardCommentDTO;
import cn.nine.pros.post.client.model.db.PostcardDTO;
import cn.nine.pros.post.client.model.input.admin.CommentQueryInDto;
import cn.nine.pros.post.client.model.input.admin.ContentRejectInDto;
import cn.nine.pros.post.client.model.input.admin.PostcardQueryInDto;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequiredArgsConstructor
@Tag(name = "管理后台-内容管理API")
public class AdminContentController implements AdminContentApi {

    private final PostcardService postcardService;
    private final PostcardMapstruct postcardMapstruct;
    private final PostcardCommentService commentService;
    private final PostcardCommentMapstruct commentMapstruct;

    @Override
    @Operation(summary = "明信片列表")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/postcard/list")
    public PageData<PostcardDTO> listPostcards(@RequestBody PostcardQueryInDto query) {
        PageQuery pageQuery = query.getPage();
        long pageNum = pageQuery.getPage();
        long pageSize = pageQuery.getSize();

        LambdaQueryWrapper<PostcardDomain> wrapper = new LambdaQueryWrapper<>();
        if (query.getReviewStatus() != null) {
            wrapper.eq(PostcardDomain::getReviewStatus, query.getReviewStatus());
        }
        wrapper.eq(PostcardDomain::isDelFlag, false);
        wrapper.orderByDesc(PostcardDomain::getCreatedAt);

        Page<PostcardDomain> page = postcardService.page(new Page<>((int) pageNum, (int) pageSize), wrapper);
        List<PostcardDTO> records = page.getRecords().stream().map(postcardMapstruct::toDTO).toList();

        PageData<PostcardDTO> result = new PageData<>();
        result.setRecords(records);
        result.setTotal(page.getTotal());
        result.setPages(page.getPages());
        result.setPage(page.getCurrent());
        result.setSize(page.getSize());
        return result;
    }

    @Override
    @Operation(summary = "审核通过明信片")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/postcard/{id}/approve")
    @Transactional
    public void approvePostcard(@PathVariable("id") Long id) {
        PostcardDomain postcard = postcardService.getById(id);
        if (postcard == null) {
            throw new cn.nine.commons.basic.exception.BadRequestException("明信片不存在");
        }
        postcard.setReviewStatus((short) 1);
        postcardService.updateById(postcard);
    }

    @Override
    @Operation(summary = "驳回明信片")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/postcard/{id}/reject")
    @Transactional
    public void rejectPostcard(@PathVariable("id") Long id, @RequestBody ContentRejectInDto req) {
        PostcardDomain postcard = postcardService.getById(id);
        if (postcard == null) {
            throw new cn.nine.commons.basic.exception.BadRequestException("明信片不存在");
        }
        postcard.setReviewStatus((short) 2);
        postcardService.updateById(postcard);
    }

    @Override
    @Operation(summary = "删除明信片")
    @DeleteMapping(AppServiceDefine.WEBAPI_PREFIX + "/postcard/{id}")
    @Transactional
    public void deletePostcard(@PathVariable("id") Long id) {
        PostcardDomain postcard = postcardService.getById(id);
        if (postcard == null) {
            throw new cn.nine.commons.basic.exception.BadRequestException("明信片不存在");
        }
        postcard.setDelFlag(true);
        postcardService.updateById(postcard);
    }

    @Override
    @Operation(summary = "评论列表")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/comment/list")
    public PageData<PostcardCommentDTO> listComments(@RequestBody CommentQueryInDto query) {
        PageQuery pageQuery = query.getPage();
        long pageNum = pageQuery.getPage();
        long pageSize = pageQuery.getSize();

        LambdaQueryWrapper<PostcardCommentDomain> wrapper = new LambdaQueryWrapper<>();
        if (query.getReviewStatus() != null) {
            wrapper.eq(PostcardCommentDomain::getReviewStatus, query.getReviewStatus());
        }
        wrapper.eq(PostcardCommentDomain::isDelFlag, false);
        wrapper.orderByDesc(PostcardCommentDomain::getCreatedAt);

        Page<PostcardCommentDomain> page = commentService.page(new Page<>((int) pageNum, (int) pageSize), wrapper);
        List<PostcardCommentDTO> records = page.getRecords().stream().map(commentMapstruct::toDTO).toList();

        PageData<PostcardCommentDTO> result = new PageData<>();
        result.setRecords(records);
        result.setTotal(page.getTotal());
        result.setPages(page.getPages());
        result.setPage(page.getCurrent());
        result.setSize(page.getSize());
        return result;
    }

    @Override
    @Operation(summary = "审核通过评论")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/comment/{id}/approve")
    @Transactional
    public void approveComment(@PathVariable("id") Long id) {
        PostcardCommentDomain comment = commentService.getById(id);
        if (comment == null) {
            throw new cn.nine.commons.basic.exception.BadRequestException("评论不存在");
        }
        comment.setReviewStatus((short) 1);
        commentService.updateById(comment);
    }

    @Override
    @Operation(summary = "驳回评论")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/comment/{id}/reject")
    @Transactional
    public void rejectComment(@PathVariable("id") Long id, @RequestBody ContentRejectInDto req) {
        PostcardCommentDomain comment = commentService.getById(id);
        if (comment == null) {
            throw new cn.nine.commons.basic.exception.BadRequestException("评论不存在");
        }
        comment.setReviewStatus((short) 2);
        commentService.updateById(comment);
    }
}
