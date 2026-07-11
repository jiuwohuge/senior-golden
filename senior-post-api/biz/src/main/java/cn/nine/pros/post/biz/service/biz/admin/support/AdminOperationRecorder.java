package cn.nine.pros.post.biz.service.biz.admin.support;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.pros.post.biz.service.base.AdminOperationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

/**
 * 管理端写操作埋点：从请求上下文取 adminId / IP，写入 log_admin_operation。
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class AdminOperationRecorder {

    private final AdminOperationService adminOperationService;

    /**
     * 记录管理员操作；无登录管理员时跳过。
     *
     * @param actionType 操作类型，如 user.status / letter.approve
     * @param targetType 目标类型，如 user / letter
     * @param targetId   目标主键
     * @param details    补充说明（可空）
     */
    public void record(String actionType, String targetType, Long targetId, String details) {
        Long adminId = MyRequestContextHolder.userId();
        if (adminId == null) {
            log.warn("skip admin operation record: no adminId, actionType={}, targetType={}, targetId={}",
                    actionType, targetType, targetId);
            return;
        }
        String ip = MyRequestContextHolder.ipAddress();
        adminOperationService.record(adminId, actionType, targetType, targetId, details, ip);
        log.info("admin op recorded, adminId={}, actionType={}, targetType={}, targetId={}",
                adminId, actionType, targetType, targetId);
    }
}
