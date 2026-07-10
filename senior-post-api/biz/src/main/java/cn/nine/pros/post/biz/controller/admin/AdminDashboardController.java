package cn.nine.pros.post.biz.controller.admin;

import cn.nine.pros.post.biz.service.biz.admin.AdminDashboardBizService;
import cn.nine.pros.post.client.api.admin.AdminDashboardApi;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequiredArgsConstructor
public class AdminDashboardController implements AdminDashboardApi {

    private final AdminDashboardBizService adminDashboardBizService;

    @Override
    public Map<String, Object> summary() {
        return adminDashboardBizService.summary();
    }
}
