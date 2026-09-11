package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.pros.post.biz.mapper.NotificationDeliveryMapper;
import cn.nine.pros.post.biz.model.domain.NotificationDeliveryDomain;
import cn.nine.pros.post.biz.service.base.NotificationDeliveryService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;

/**
 * {@link NotificationDeliveryService} 实现。
 */
@Service
public class NotificationDeliveryServiceImpl
        extends ServiceImpl<NotificationDeliveryMapper, NotificationDeliveryDomain>
        implements NotificationDeliveryService {

    @Override
    public NotificationDeliveryDomain insertDelivery(NotificationDeliveryDomain row) {
        if (row == null) {
            return null;
        }
        save(row);
        return row;
    }

    @Override
    public List<NotificationDeliveryDomain> listByOutboxId(long outboxId) {
        List<NotificationDeliveryDomain> list = list(new LambdaQueryWrapper<NotificationDeliveryDomain>()
                .eq(NotificationDeliveryDomain::getOutboxId, outboxId)
                .eq(NotificationDeliveryDomain::isDelFlag, false)
                .orderByAsc(NotificationDeliveryDomain::getId));
        return list != null ? list : Collections.emptyList();
    }
}
