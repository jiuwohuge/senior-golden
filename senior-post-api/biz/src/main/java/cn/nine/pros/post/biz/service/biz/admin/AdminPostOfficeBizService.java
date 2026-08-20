package cn.nine.pros.post.biz.service.biz.admin;

import cn.nine.pros.post.biz.model.domain.ConfigDomain;
import cn.nine.pros.post.biz.service.base.ConfigService;
import cn.nine.pros.post.biz.service.base.LetterService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.client.common.constant.HomeRecommendedAction;
import cn.nine.pros.post.client.model.out.AdminPostOfficePoolStatusVO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

/**
 * 管理端冷启动：池子只读数字 + 当前首页主推配置。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AdminPostOfficeBizService {

    private final LetterService letterService;
    private final UserService userService;
    private final ConfigService configService;

    /**
     * 供作者判断何时把首页从时光信切到有缘人。
     */
    public AdminPostOfficePoolStatusVO poolStatus() {
        long waiting = letterService.countWaitingMatch();
        long active = userService.countActiveAppUsers();
        ConfigDomain cfg = configService.findActiveByKey(HomeRecommendedAction.CONFIG_KEY);
        String action = HomeRecommendedAction.normalize(cfg == null ? null : cfg.getConfigValue());
        boolean canMatchNow = waiting == 0 && active > 0;
        log.info("admin pool-status waiting={}, active={}, action={}", waiting, active, action);
        return AdminPostOfficePoolStatusVO.builder()
                .waitingMatchCount(waiting)
                .activeUserCount(active)
                .canMatchNow(canMatchNow)
                .recommendedAction(action)
                .recommendedActionConfigId(cfg == null ? null : cfg.getId())
                .build();
    }
}
