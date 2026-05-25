package cn.nine.pros.post.biz.controller.app;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.service.app.AppPostcardService;
import cn.nine.pros.post.client.api.app.AppPostcardApi;
import cn.nine.pros.post.client.model.input.app.AppPostcardCommentCreateInDto;
import cn.nine.pros.post.client.model.input.app.AppPostcardCommentPageInDto;
import cn.nine.pros.post.client.model.input.app.AppPostcardCreateInDto;
import cn.nine.pros.post.client.model.input.app.AppPostcardPageInDto;
import cn.nine.pros.post.client.model.out.PostcardCommentItemVO;
import cn.nine.pros.post.client.model.out.PostcardCommentLikeVO;
import cn.nine.pros.post.client.model.out.PostcardDetailVO;
import cn.nine.pros.post.client.model.out.PostcardWallItemVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class AppPostcardController implements AppPostcardApi {

    private final AppPostcardService appPostcardService;
    private final AppMessages appMessages;

    @Override
    public PageData<PostcardWallItemVO> paging(AppPostcardPageInDto body) {
        long uid = requireUserId();
        return appPostcardService.wallPage(uid, body);
    }

    @Override
    public PageData<PostcardWallItemVO> minePaging(AppPostcardPageInDto body) {
        long uid = requireUserId();
        return appPostcardService.minePage(uid, body);
    }

    @Override
    public PageData<PostcardWallItemVO> userPostcardsPaging(Long userId, AppPostcardPageInDto body) {
        long uid = requireUserId();
        return appPostcardService.userPostcardsPage(uid, userId, body);
    }

    @Override
    public PostcardDetailVO getDetail(Long postcardId) {
        long uid = requireUserId();
        return appPostcardService.getDetail(uid, postcardId);
    }

    @Override
    public PostcardDetailVO create(AppPostcardCreateInDto body) {
        long uid = requireUserId();
        return appPostcardService.create(uid, body);
    }

    @Override
    public PageData<PostcardCommentItemVO> commentsPaging(Long postcardId, AppPostcardCommentPageInDto body) {
        long uid = requireUserId();
        return appPostcardService.commentsPage(uid, postcardId, body);
    }

    @Override
    public PostcardCommentItemVO createComment(Long postcardId, AppPostcardCommentCreateInDto body) {
        long uid = requireUserId();
        return appPostcardService.createComment(uid, postcardId, body);
    }

    @Override
    public PostcardCommentLikeVO toggleCommentLike(Long postcardId, Long commentId) {
        long uid = requireUserId();
        return appPostcardService.toggleCommentLike(uid, postcardId, commentId);
    }

    private long requireUserId() {
        Long uid = MyRequestContextHolder.userId();
        if (uid == null) {
            throw new BadRequestException(appMessages.get("app.error.notLoggedIn"));
        }
        return uid;
    }
}
