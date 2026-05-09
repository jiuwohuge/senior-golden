package cn.nine.pros.post.biz.controller.app;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.service.app.AppPostcardService;
import cn.nine.pros.post.client.api.app.AppPostcardApi;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.input.app.AppPostcardCommentCreateInDto;
import cn.nine.pros.post.client.model.input.app.AppPostcardCommentPageInDto;
import cn.nine.pros.post.client.model.input.app.AppPostcardCreateInDto;
import cn.nine.pros.post.client.model.input.app.AppPostcardPageInDto;
import cn.nine.pros.post.client.model.out.PostcardCommentItemVO;
import cn.nine.pros.post.client.model.out.PostcardDetailVO;
import cn.nine.pros.post.client.model.out.PostcardWallItemVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@Tag(name = "App-明信片墙")
public class AppPostcardController implements AppPostcardApi {

    private final AppPostcardService appPostcardService;
    private final AppMessages appMessages;

    @Override
    @Operation(summary = "明信片墙分页（仅审核通过且公开）")
    @PostMapping(AppServiceDefine.SERVER_PREFIX + "/postcards/paging")
    public PageData<PostcardWallItemVO> paging(@RequestBody @Valid AppPostcardPageInDto body) {
        long uid = requireUserId();
        return appPostcardService.wallPage(uid, body);
    }

    @Override
    @Operation(summary = "我的明信片分页（含待审/驳回，仅本人）")
    @PostMapping(AppServiceDefine.SERVER_PREFIX + "/postcards/mine/paging")
    public PageData<PostcardWallItemVO> minePaging(@RequestBody @Valid AppPostcardPageInDto body) {
        long uid = requireUserId();
        return appPostcardService.minePage(uid, body);
    }

    @Override
    @Operation(summary = "明信片详情（公开仅已通过；作者可查看待审/驳回）")
    @GetMapping(AppServiceDefine.SERVER_PREFIX + "/postcards/{postcardId}")
    public PostcardDetailVO getDetail(@PathVariable("postcardId") Long postcardId) {
        long uid = requireUserId();
        return appPostcardService.getDetail(uid, postcardId);
    }

    @Override
    @Operation(summary = "发布明信片（进入待审核）")
    @PostMapping(AppServiceDefine.SERVER_PREFIX + "/postcards")
    public PostcardDetailVO create(@RequestBody @Valid AppPostcardCreateInDto body) {
        long uid = requireUserId();
        return appPostcardService.create(uid, body);
    }

    @Override
    @Operation(summary = "评论分页（仅已通过审核）")
    @PostMapping(AppServiceDefine.SERVER_PREFIX + "/postcards/{postcardId}/comments/paging")
    public PageData<PostcardCommentItemVO> commentsPaging(
            @PathVariable("postcardId") Long postcardId,
            @RequestBody @Valid AppPostcardCommentPageInDto body) {
        long uid = requireUserId();
        return appPostcardService.commentsPage(uid, postcardId, body);
    }

    @Override
    @Operation(summary = "发表评论（待审核）")
    @PostMapping(AppServiceDefine.SERVER_PREFIX + "/postcards/{postcardId}/comments")
    public PostcardCommentItemVO createComment(
            @PathVariable("postcardId") Long postcardId,
            @RequestBody @Valid AppPostcardCommentCreateInDto body) {
        long uid = requireUserId();
        return appPostcardService.createComment(uid, postcardId, body);
    }

    private long requireUserId() {
        Long uid = MyRequestContextHolder.userId();
        if (uid == null) {
            throw new BadRequestException(appMessages.get("app.error.notLoggedIn"));
        }
        return uid;
    }
}
