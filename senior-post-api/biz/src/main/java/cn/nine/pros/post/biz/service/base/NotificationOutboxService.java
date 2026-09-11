package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.NotificationOutboxDomain;
import com.baomidou.mybatisplus.extension.service.IService;

import java.util.List;

/**
 * 推送通知 Outbox Base Service。
 */
public interface NotificationOutboxService extends IService<NotificationOutboxDomain> {

    /** 按 dedupe_key 查未删除行。 */
    NotificationOutboxDomain findByDedupeKey(String dedupeKey);

    /** 保存新 pending 行。 */
    NotificationOutboxDomain insertPending(NotificationOutboxDomain row);

    /**
     * 认领一批 pending（status pending → processing）。
     * @return 已认领行
     */
    List<NotificationOutboxDomain> claimPendingBatch(int limit);

    /** 标记已发送。 */
    boolean markSent(long id);

    /** 标记失败（可重试或终态）。 */
    boolean markFailed(long id, String error, boolean terminal);
}
