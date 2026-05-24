package cn.nine.pros.post.client.api.app;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.input.app.AppPostcardCommentCreateInDto;
import cn.nine.pros.post.client.model.input.app.AppPostcardCommentPageInDto;
import cn.nine.pros.post.client.model.input.app.AppPostcardCreateInDto;
import cn.nine.pros.post.client.model.input.app.AppPostcardPageInDto;
import cn.nine.pros.post.client.model.out.PostcardCommentItemVO;
import cn.nine.pros.post.client.model.out.PostcardCommentLikeVO;
import cn.nine.pros.post.client.model.out.PostcardDetailVO;
import cn.nine.pros.post.client.model.out.PostcardWallItemVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

@Tag(name = "App-明信片墙")
@RequestMapping(AppServiceDefine.SERVER_PREFIX + "/postcards")
public interface AppPostcardApi {

    @Operation(summary = "明信片墙分页（仅审核通过且公开）")
    @PostMapping("/paging")
    PageData<PostcardWallItemVO> paging(@RequestBody @Valid AppPostcardPageInDto body);

    @Operation(summary = "我的明信片分页（含待审/驳回，仅本人）")
    @PostMapping("/mine/paging")
    PageData<PostcardWallItemVO> minePaging(@RequestBody @Valid AppPostcardPageInDto body);

    @Operation(summary = "明信片详情（公开仅已通过；作者可查看待审/驳回）")
    @GetMapping("/{postcardId}")
    PostcardDetailVO getDetail(@PathVariable("postcardId") Long postcardId);

    @Operation(summary = "发布明信片（进入待审核）")
    @PostMapping
    PostcardDetailVO create(@RequestBody @Valid AppPostcardCreateInDto body);

    @Operation(summary = "评论分页（仅已通过审核）")
    @PostMapping("/{postcardId}/comments/paging")
    PageData<PostcardCommentItemVO> commentsPaging(
            @PathVariable("postcardId") Long postcardId,
            @RequestBody @Valid AppPostcardCommentPageInDto body);

    @Operation(summary = "发表评论（待审核）")
    @PostMapping("/{postcardId}/comments")
    PostcardCommentItemVO createComment(
            @PathVariable("postcardId") Long postcardId,
            @RequestBody @Valid AppPostcardCommentCreateInDto body);

    @Operation(summary = "切换评论点赞")
    @PostMapping("/{postcardId}/comments/{commentId}/like")
    PostcardCommentLikeVO toggleCommentLike(
            @PathVariable("postcardId") Long postcardId,
            @PathVariable("commentId") Long commentId);
}
