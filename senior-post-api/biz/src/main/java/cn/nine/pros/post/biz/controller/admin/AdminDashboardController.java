package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.pros.post.biz.model.domain.UserDomain;
import cn.nine.pros.post.biz.model.domain.PostcardDomain;
import cn.nine.pros.post.biz.service.base.PostcardService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.client.api.admin.AdminDashboardApi;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.out.DashboardStatsVO;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;

@Slf4j
@RestController
@RequiredArgsConstructor
@Tag(name = "管理后台-仪表盘API")
public class AdminDashboardController implements AdminDashboardApi {

    private final UserService userService;
    private final PostcardService postcardService;

    @Override
    @Operation(summary = "获取仪表盘统计")
    @GetMapping(AppServiceDefine.WEBAPI_PREFIX + "/dashboard/stats")
    public DashboardStatsVO getDashboardStats() {
        DashboardStatsVO stats = new DashboardStatsVO();

        stats.setTotalUsers(userService.count());
        stats.setTodayNewUsers(userService.count(
                new LambdaQueryWrapper<UserDomain>()
                        .ge(UserDomain::getCreatedAt, LocalDate.now().atStartOfDay())
        ));
        stats.setDailyActiveUsers(userService.count(
                new LambdaQueryWrapper<UserDomain>()
                        .ge(UserDomain::getLastLoginAt, LocalDate.now().atStartOfDay())
        ));
        stats.setTotalPostcards(postcardService.count());
        stats.setTotalLetters(0L);
        stats.setVipCount(userService.count(
                new LambdaQueryWrapper<UserDomain>()
                        .eq(UserDomain::getIsVip, true)
        ));

        return stats;
    }
}