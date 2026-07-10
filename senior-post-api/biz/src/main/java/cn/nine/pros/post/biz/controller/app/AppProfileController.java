package cn.nine.pros.post.biz.controller.app;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.service.biz.AppProfileBizService;
import cn.nine.pros.post.client.api.app.AppProfileApi;
import cn.nine.pros.post.client.model.input.app.UserPreferencesPatchInDto;
import cn.nine.pros.post.client.model.out.ProfileOverviewVO;
import cn.nine.pros.post.client.model.out.UserPreferencesVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class AppProfileController implements AppProfileApi {

    private final AppProfileBizService appProfileBizService;
    private final AppMessages appMessages;

    @Override
    public ProfileOverviewVO overview() {
        return appProfileBizService.overview(requireUserId());
    }

    @Override
    public UserPreferencesVO preferences() {
        return appProfileBizService.preferences(requireUserId());
    }

    @Override
    public UserPreferencesVO patchPreferences(UserPreferencesPatchInDto body) {
        return appProfileBizService.patchPreferences(requireUserId(), body);
    }

    private Long requireUserId() {
        Long uid = MyRequestContextHolder.userId();
        if (uid == null) {
            throw new BadRequestException(appMessages.get("app.error.notLoggedIn"));
        }
        return uid;
    }
}
