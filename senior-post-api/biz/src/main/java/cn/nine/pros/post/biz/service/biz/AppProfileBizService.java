package cn.nine.pros.post.biz.service.biz;

import cn.nine.pros.post.client.model.input.app.UserPreferencesPatchInDto;
import cn.nine.pros.post.client.model.out.ProfileOverviewVO;
import cn.nine.pros.post.client.model.out.UserPreferencesVO;

public interface AppProfileBizService {

    ProfileOverviewVO overview(long userId);

    UserPreferencesVO preferences(long userId);

    UserPreferencesVO patchPreferences(long userId, UserPreferencesPatchInDto body);
}
