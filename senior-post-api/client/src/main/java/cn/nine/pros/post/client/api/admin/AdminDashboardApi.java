package cn.nine.pros.post.client.api.admin;

import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.out.DashboardStatsVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.*;

@Tag(name = "管理后台-仪表盘API")
public interface AdminDashboardApi {

    @Operation(summary = "获取仪表盘统计")
    @GetMapping(AppServiceDefine.WEBAPI_PREFIX + "/dashboard/stats")
    DashboardStatsVO getDashboardStats();
}