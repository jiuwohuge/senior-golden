package cn.nine.pros.post.biz.service.biz.admin;

import cn.nine.pros.post.biz.service.base.FriendshipService;
import cn.nine.pros.post.biz.service.base.LetterService;
import cn.nine.pros.post.biz.service.base.MailOutboxService;
import cn.nine.pros.post.biz.service.base.ReportService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.biz.service.base.VipSubscriptionService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 管理端仪表盘汇总指标与近 7 日序列。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AdminDashboardBizService {

    private final UserService userService;
    private final LetterService letterService;
    private final ReportService reportService;
    private final VipSubscriptionService vipSubscriptionService;
    private final MailOutboxService mailOutboxService;
    private final FriendshipService friendshipService;

    /**
     * 汇总活跃用户、信件、待处理举报、VIP、今日增量、在途/待审、邮件失败、笔友与近 7 日序列。
     */
    public Map<String, Object> summary() {
        LocalDate today = LocalDate.now();
        LocalDateTime dayStart = today.atStartOfDay();
        LocalDateTime dayEnd = today.plusDays(1).atStartOfDay();

        Map<String, Object> m = new HashMap<>();
        m.put("users", userService.countActiveAppUsers());
        m.put("letters", letterService.countActive());
        m.put("reportsPending", reportService.countPending());
        m.put("vipSubscriptions", vipSubscriptionService.countActive());
        m.put("usersToday", userService.countCreatedBetween(dayStart, dayEnd));
        m.put("lettersToday", letterService.countCreatedBetween(dayStart, dayEnd));
        m.put("lettersInTransit", letterService.countInTransit());
        m.put("lettersPendingAudit", letterService.countPendingAudit());
        m.put("mailOutboxFailed", mailOutboxService.countByStatus("failed"));
        m.put("penpalCount", friendshipService.countActive());
        m.put("series7d", buildSeries7d(today));
        log.info("admin dashboard summary built, usersToday={}, lettersToday={}",
                m.get("usersToday"), m.get("lettersToday"));
        return m;
    }

    private List<Map<String, Object>> buildSeries7d(LocalDate today) {
        List<Map<String, Object>> series = new ArrayList<>(7);
        for (int i = 6; i >= 0; i--) {
            LocalDate day = today.minusDays(i);
            LocalDateTime start = day.atStartOfDay();
            LocalDateTime end = day.plusDays(1).atStartOfDay();
            Map<String, Object> point = new HashMap<>(4);
            point.put("date", day.toString());
            point.put("users", userService.countCreatedBetween(start, end));
            point.put("letters", letterService.countCreatedBetween(start, end));
            series.add(point);
        }
        return series;
    }
}
