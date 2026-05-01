package cn.nine.pros.post.client.api.admin;

import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.Map;

@Tag(name = "管理后台-看板")
public interface AdminDashboardApi {

    @Operation(summary = "看板汇总")
    @GetMapping(AppServiceDefine.WEBAPI_PREFIX + "/dashboard/summary")
    Map<String, Object> summary();
}
