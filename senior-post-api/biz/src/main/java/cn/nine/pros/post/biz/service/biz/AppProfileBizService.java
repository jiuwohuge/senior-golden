package cn.nine.pros.post.biz.service.biz;

import cn.nine.pros.post.client.model.out.ProfileOverviewVO;

public interface AppProfileBizService {

    ProfileOverviewVO overview(long userId);
}
