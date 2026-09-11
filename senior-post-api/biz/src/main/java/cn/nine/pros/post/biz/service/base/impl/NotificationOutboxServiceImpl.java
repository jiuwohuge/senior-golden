package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.pros.post.biz.mapper.NotificationOutboxMapper;
import cn.nine.pros.post.biz.model.domain.NotificationOutboxDomain;
import cn.nine.pros.post.biz.service.base.NotificationOutboxService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * {@link NotificationOutboxService} 实现：认领风格对齐 MailOutbox（list + status 更新）。
 */
@Slf4j
@Service
public class NotificationOutboxServiceImpl
        extends ServiceImpl<NotificationOutboxMapper, NotificationOutboxDomain>
        implements NotificationOutboxService {

    @Override
    public NotificationOutboxDomain findByDedupeKey(String dedupeKey) {
        if (!StringUtils.hasText(dedupeKey)) {
            return null;
        }
        return getOne(new LambdaQueryWrapper<NotificationOutboxDomain>()
                .eq(NotificationOutboxDomain::getDedupeKey, dedupeKey.trim())
                .eq(NotificationOutboxDomain::isDelFlag, false)
                .last("LIMIT 1"), false);
    }

    @Override
    public NotificationOutboxDomain insertPending(NotificationOutboxDomain row) {
        if (row == null) {
            return null;
        }
        save(row);
        return row;
    }

    @Override
    public List<NotificationOutboxDomain> claimPendingBatch(int limit) {
        int batch = Math.max(1, limit);
        LocalDateTime now = LocalDateTime.now();
        List<NotificationOutboxDomain> rows = list(new LambdaQueryWrapper<NotificationOutboxDomain>()
                .eq(NotificationOutboxDomain::getStatus, "pending")
                .eq(NotificationOutboxDomain::isDelFlag, false)
                .and(w -> w.isNull(NotificationOutboxDomain::getNextRetryAt)
                        .or()
                        .le(NotificationOutboxDomain::getNextRetryAt, now))
                .orderByAsc(NotificationOutboxDomain::getId)
                .last("LIMIT " + batch));
        if (rows == null || rows.isEmpty()) {
            return Collections.emptyList();
        }
        List<NotificationOutboxDomain> claimed = new ArrayList<>();
        for (NotificationOutboxDomain row : rows) {
            boolean ok = update(new LambdaUpdateWrapper<NotificationOutboxDomain>()
                    .eq(NotificationOutboxDomain::getId, row.getId())
                    .eq(NotificationOutboxDomain::getStatus, "pending")
                    .set(NotificationOutboxDomain::getStatus, "processing")
                    .set(NotificationOutboxDomain::getUpdatedAt, now));
            if (!ok) {
                continue;
            }
            row.setStatus("processing");
            claimed.add(row);
        }
        return claimed;
    }

    @Override
    public boolean markSent(long id) {
        LocalDateTime now = LocalDateTime.now();
        return update(new LambdaUpdateWrapper<NotificationOutboxDomain>()
                .eq(NotificationOutboxDomain::getId, id)
                .set(NotificationOutboxDomain::getStatus, "sent")
                .set(NotificationOutboxDomain::getProcessedAt, now)
                .set(NotificationOutboxDomain::getLastError, null)
                .set(NotificationOutboxDomain::getUpdatedAt, now));
    }

    @Override
    public boolean markFailed(long id, String error, boolean terminal) {
        LocalDateTime now = LocalDateTime.now();
        NotificationOutboxDomain row = getById(id);
        int attempts = row != null && row.getAttempts() != null ? row.getAttempts() + 1 : 1;
        String msg = error;
        if (msg != null && msg.length() > 2000) {
            msg = msg.substring(0, 2000);
        }
        String status = terminal ? "failed" : "pending";
        LocalDateTime nextRetry = terminal ? null : now.plusSeconds(Math.min(3600L, 30L * (1L << Math.min(attempts, 6))));
        return update(new LambdaUpdateWrapper<NotificationOutboxDomain>()
                .eq(NotificationOutboxDomain::getId, id)
                .set(NotificationOutboxDomain::getStatus, status)
                .set(NotificationOutboxDomain::getAttempts, attempts)
                .set(NotificationOutboxDomain::getLastError, msg)
                .set(NotificationOutboxDomain::getNextRetryAt, nextRetry)
                .set(NotificationOutboxDomain::getProcessedAt, terminal ? now : null)
                .set(NotificationOutboxDomain::getUpdatedAt, now));
    }
}
