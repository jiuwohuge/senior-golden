package cn.nine.pros.post.client.api.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.db.PostcardCommentDTO;
import cn.nine.pros.post.client.model.db.PostcardDTO;
import cn.nine.pros.post.client.model.input.admin.CommentQueryInDto;
import cn.nine.pros.post.client.model.input.admin.ContentRejectInDto;
import cn.nine.pros.post.client.model.input.admin.PostcardQueryInDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@Tag(name = "管理后台-内容管理API")
public interface AdminContentApi {

    @Operation(summary = "明信片列表")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/postcard/list")
    PageData<PostcardDTO> listPostcards(@RequestBody @Validated PostcardQueryInDto query);

    @Operation(summary = "审核通过明信片")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/postcard/{id}/approve")
    void approvePostcard(@PathVariable("id") Long id);

    @Operation(summary = "驳回明信片")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/postcard/{id}/reject")
    void rejectPostcard(@PathVariable("id") Long id, @RequestBody @Validated ContentRejectInDto req);

    @Operation(summary = "删除明信片")
    @DeleteMapping(AppServiceDefine.WEBAPI_PREFIX + "/postcard/{id}")
    void deletePostcard(@PathVariable("id") Long id);

    @Operation(summary = "评论列表")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/comment/list")
    PageData<PostcardCommentDTO> listComments(@RequestBody @Validated CommentQueryInDto query);

    @Operation(summary = "审核通过评论")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/comment/{id}/approve")
    void approveComment(@PathVariable("id") Long id);

    @Operation(summary = "驳回评论")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/comment/{id}/reject")
    void rejectComment(@PathVariable("id") Long id, @RequestBody @Validated ContentRejectInDto req);
}