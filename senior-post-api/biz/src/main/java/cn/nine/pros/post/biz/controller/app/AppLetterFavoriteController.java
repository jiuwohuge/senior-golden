package cn.nine.pros.post.biz.controller.app;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.service.biz.AppLetterFavoriteBizService;
import cn.nine.pros.post.client.api.app.AppLetterFavoriteApi;
import cn.nine.pros.post.client.model.out.MailboxLetterItemVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class AppLetterFavoriteController implements AppLetterFavoriteApi {

    private final AppLetterFavoriteBizService appLetterFavoriteBizService;
    private final AppMessages appMessages;

    @Override
    public void favorite(Long id) {
        appLetterFavoriteBizService.favorite(requireUserId(), id);
    }

    @Override
    public void unfavorite(Long id) {
        appLetterFavoriteBizService.unfavorite(requireUserId(), id);
    }

    @Override
    public List<MailboxLetterItemVO> listFavorites() {
        return appLetterFavoriteBizService.listFavorites(requireUserId());
    }

    private Long requireUserId() {
        Long uid = MyRequestContextHolder.userId();
        if (uid == null) {
            throw new BadRequestException(appMessages.get("app.error.notLoggedIn"));
        }
        return uid;
    }
}
