package cn.nine.pros.post.biz.service.app;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.client.model.input.app.AppPostcardCommentCreateInDto;
import cn.nine.pros.post.client.model.input.app.AppPostcardCommentPageInDto;
import cn.nine.pros.post.client.model.input.app.AppPostcardCreateInDto;
import cn.nine.pros.post.client.model.input.app.AppPostcardPageInDto;
import cn.nine.pros.post.client.model.out.PostcardCommentItemVO;
import cn.nine.pros.post.client.model.out.PostcardCommentLikeVO;
import cn.nine.pros.post.client.model.out.PostcardDetailVO;
import cn.nine.pros.post.client.model.out.PostcardWallItemVO;

public interface AppPostcardService {

    PageData<PostcardWallItemVO> wallPage(long userId, AppPostcardPageInDto body);

    PageData<PostcardWallItemVO> minePage(long userId, AppPostcardPageInDto body);

    PostcardDetailVO getDetail(long viewerUserId, Long postcardId);

    PostcardDetailVO create(long userId, AppPostcardCreateInDto body);

    PageData<PostcardCommentItemVO> commentsPage(long viewerUserId, Long postcardId, AppPostcardCommentPageInDto body);

    PostcardCommentItemVO createComment(long userId, Long postcardId, AppPostcardCommentCreateInDto body);

    PostcardCommentLikeVO toggleCommentLike(long userId, Long postcardId, Long commentId);
}
