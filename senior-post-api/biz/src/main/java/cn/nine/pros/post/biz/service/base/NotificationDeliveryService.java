package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.NotificationDeliveryDomain;
import com.baomidou.mybatisplus.extension.service.IService;

import java.util.List;

/**
 * 推送投递结果 Base Service。
 */
public interface NotificationDeliveryService extends IService<NotificationDeliveryDomain> {

    /** 写入一条投递结果。 */
    NotificationDeliveryDomain insertDelivery(NotificationDeliveryDomain row);

    /** 某 outbox 下全部投递行（QA 汇总）。 */
    List<NotificationDeliveryDomain> listByOutboxId(long outboxId);
}
