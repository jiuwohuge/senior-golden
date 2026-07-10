package cn.nine.pros.post.biz.controller.admin;

import cn.nine.pros.post.biz.service.base.*;
import cn.nine.pros.post.client.api.admin.AdminDashboardApi;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequiredArgsConstructor
public class AdminDashboardController implements AdminDashboardApi {

    private final UserService userService;
    private final LetterService letterService;
    private final ReportService reportService;
    private final VipSubscriptionService vipSubscriptionService;

    @Override
    public Map<String, Object> summary() {
        Map<String, Object> m = new HashMap<>();
        m.put("users", userService.countActiveAppUsers());
        m.put("letters", letterService.count());
        m.put("reportsPending", reportService.lambdaQuery().eq(cn.nine.pros.post.biz.model.domain.ReportDomain::getStatus, 0).count());
        m.put("vipSubscriptions", vipSubscriptionService.count());
        return m;
    }
}
