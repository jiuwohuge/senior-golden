package cn.nine.pros.post.biz.service.biz.admin;

import cn.nine.pros.post.biz.service.base.LetterService;
import cn.nine.pros.post.biz.service.base.ReportService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.biz.service.base.VipSubscriptionService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

/**
 * 管理端仪表盘汇总指标。
 */
@Service
@RequiredArgsConstructor
public class AdminDashboardBizService {

    private final UserService userService;
    private final LetterService letterService;
    private final ReportService reportService;
    private final VipSubscriptionService vipSubscriptionService;

    /**
     * 汇总活跃用户、信件、待处理举报与 VIP 订阅数。
     */
    public Map<String, Object> summary() {
        Map<String, Object> m = new HashMap<>();
        m.put("users", userService.countActiveAppUsers());
        m.put("letters", letterService.countActive());
        m.put("reportsPending", reportService.countPending());
        m.put("vipSubscriptions", vipSubscriptionService.countActive());
        return m;
    }
}
