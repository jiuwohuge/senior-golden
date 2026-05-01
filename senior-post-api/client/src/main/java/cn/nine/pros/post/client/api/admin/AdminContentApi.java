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
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

@Tag(name = "管理后台-内容")
public interface AdminContentApi {

    @Operation(summary = "分页查询明信片")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/content/postcard/paging")
    PageData<PostcardDTO> pagingPostcards(@RequestBody @Valid PostcardQueryInDto body);

    @Operation(summary = "分页查询评论")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/content/comment/paging")
    PageData<PostcardCommentDTO> pagingComments(@RequestBody @Valid CommentQueryInDto body);

    @Operation(summary = "审核通过明信片")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/content/postcard/{id}/approve")
    void approvePostcard(@PathVariable("id") Long id);

    @Operation(summary = "驳回明信片")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/content/postcard/{id}/reject")
    void rejectPostcard(@PathVariable("id") Long id, @RequestBody @Valid ContentRejectInDto body);

    @Operation(summary = "审核通过评论")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/content/comment/{id}/approve")
    void approveComment(@PathVariable("id") Long id);

    @Operation(summary = "驳回评论")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/content/comment/{id}/reject")
    void rejectComment(@PathVariable("id") Long id, @RequestBody @Valid ContentRejectInDto body);
}
