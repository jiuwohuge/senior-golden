package cn.nine.pros.post.client.api.app;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.client.model.input.app.AppPostcardCommentCreateInDto;
import cn.nine.pros.post.client.model.input.app.AppPostcardCommentPageInDto;
import cn.nine.pros.post.client.model.input.app.AppPostcardCreateInDto;
import cn.nine.pros.post.client.model.input.app.AppPostcardPageInDto;
import cn.nine.pros.post.client.model.out.PostcardCommentItemVO;
import cn.nine.pros.post.client.model.out.PostcardDetailVO;
import cn.nine.pros.post.client.model.out.PostcardWallItemVO;

/**
 * App 明信片墙契约。具体 {@code @RequestMapping} 在 {@code AppPostcardController} 上声明，
 * 避免仅写在接口上时部分运行环境下未注册到 Spring MVC 的问题。
 */
public interface AppPostcardApi {

    PageData<PostcardWallItemVO> paging(AppPostcardPageInDto body);

    PostcardDetailVO getDetail(Long postcardId);

    PostcardDetailVO create(AppPostcardCreateInDto body);

    PageData<PostcardCommentItemVO> commentsPaging(Long postcardId, AppPostcardCommentPageInDto body);

    PostcardCommentItemVO createComment(Long postcardId, AppPostcardCommentCreateInDto body);
}
