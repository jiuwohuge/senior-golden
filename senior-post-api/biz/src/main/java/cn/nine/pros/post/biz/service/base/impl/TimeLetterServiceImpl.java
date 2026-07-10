package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.support.PageQueryNormalize;
import cn.nine.pros.post.biz.mapper.TimeLetterMapper;
import cn.nine.pros.post.biz.model.domain.TimeLetterDomain;
import cn.nine.pros.post.biz.service.base.TimeLetterService;
import cn.nine.pros.post.client.common.enums.TimeLetterStatus;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class TimeLetterServiceImpl extends ServiceImpl<TimeLetterMapper, TimeLetterDomain>
        implements TimeLetterService {

    private static Page<TimeLetterDomain> mpPage(PageQuery pq) {
        long page = pq.getPage() == null || pq.getPage() < 1 ? 1L : pq.getPage();
        long size = pq.getSize() == null || pq.getSize() < 1 ? 20L : pq.getSize();
        return new Page<>(page, size);
    }

    @Override
    public TimeLetterDomain findBySenderAndSealRequestId(long senderId, String sealRequestId) {
        return getOne(new LambdaQueryWrapper<TimeLetterDomain>()
                .eq(TimeLetterDomain::getSenderId, senderId)
                .eq(TimeLetterDomain::getSealRequestId, sealRequestId)
                .eq(TimeLetterDomain::isDelFlag, false)
                .last("LIMIT 1"));
    }

    @Override
    public boolean cancelPending(long letterId, long senderId, LocalDateTime at) {
        return update(new LambdaUpdateWrapper<TimeLetterDomain>()
                .eq(TimeLetterDomain::getId, letterId)
                .eq(TimeLetterDomain::getSenderId, senderId)
                .eq(TimeLetterDomain::isDelFlag, false)
                .eq(TimeLetterDomain::getStatus, TimeLetterStatus.PENDING.getCode())
                .set(TimeLetterDomain::getStatus, TimeLetterStatus.CANCELLED.getCode())
                .set(TimeLetterDomain::getCancelledAt, at)
                .set(TimeLetterDomain::getUpdatedAt, at)
                .set(TimeLetterDomain::getUpdatedBy, senderId));
    }

    @Override
    public boolean markRead(long letterId, long actorUserId, LocalDateTime at) {
        return update(new LambdaUpdateWrapper<TimeLetterDomain>()
                .eq(TimeLetterDomain::getId, letterId)
                .eq(TimeLetterDomain::isDelFlag, false)
                .eq(TimeLetterDomain::getStatus, TimeLetterStatus.DELIVERED.getCode())
                .set(TimeLetterDomain::getStatus, TimeLetterStatus.READ.getCode())
                .set(TimeLetterDomain::getReadAt, at)
                .set(TimeLetterDomain::getUpdatedAt, at)
                .set(TimeLetterDomain::getUpdatedBy, actorUserId));
    }

    @Override
    public boolean updateStarFlag(long letterId, long actorUserId, boolean starFlag) {
        return update(new LambdaUpdateWrapper<TimeLetterDomain>()
                .eq(TimeLetterDomain::getId, letterId)
                .set(TimeLetterDomain::getStarFlag, starFlag)
                .set(TimeLetterDomain::getUpdatedAt, LocalDateTime.now())
                .set(TimeLetterDomain::getUpdatedBy, actorUserId));
    }

    @Override
    public boolean adminTakedown(long letterId, String reason, LocalDateTime at) {
        return update(new LambdaUpdateWrapper<TimeLetterDomain>()
                .eq(TimeLetterDomain::getId, letterId)
                .eq(TimeLetterDomain::isDelFlag, false)
                .set(TimeLetterDomain::getTakedownReason, reason)
                .set(TimeLetterDomain::getStatus, TimeLetterStatus.FAILED.getCode())
                .set(TimeLetterDomain::getUpdatedAt, at)
                .set(TimeLetterDomain::getUpdatedBy, 0L));
    }

    @Override
    public Page<TimeLetterDomain> pageOutbox(long userId, boolean starredOnly, PageQuery pageQuery) {
        LambdaQueryWrapper<TimeLetterDomain> qw = new LambdaQueryWrapper<TimeLetterDomain>()
                .eq(TimeLetterDomain::getSenderId, userId)
                .eq(TimeLetterDomain::isDelFlag, false)
                .ne(TimeLetterDomain::getStatus, TimeLetterStatus.DRAFT.getCode());
        if (starredOnly) {
            qw.eq(TimeLetterDomain::getStarFlag, true);
        }
        qw.orderByDesc(TimeLetterDomain::getCreatedAt);
        return page(mpPage(pageQuery), qw);
    }

    @Override
    public Page<TimeLetterDomain> pageInbox(long userId, PageQuery pageQuery) {
        return page(mpPage(pageQuery), new LambdaQueryWrapper<TimeLetterDomain>()
                .and(w -> w.eq(TimeLetterDomain::getRecipientId, userId)
                        .or(o -> o.isNull(TimeLetterDomain::getRecipientId)
                                .eq(TimeLetterDomain::getSenderId, userId)))
                .eq(TimeLetterDomain::isDelFlag, false)
                .in(TimeLetterDomain::getStatus,
                        TimeLetterStatus.DELIVERED.getCode(),
                        TimeLetterStatus.READ.getCode())
                .orderByDesc(TimeLetterDomain::getDeliveredAt));
    }

    @Override
    public Page<TimeLetterDomain> pageMemorial(long userId, boolean starredOnly, PageQuery pageQuery) {
        LambdaQueryWrapper<TimeLetterDomain> qw = new LambdaQueryWrapper<TimeLetterDomain>()
                .eq(TimeLetterDomain::isDelFlag, false)
                .eq(TimeLetterDomain::getStatus, TimeLetterStatus.READ.getCode())
                .and(w -> w.eq(TimeLetterDomain::getSenderId, userId)
                        .or().eq(TimeLetterDomain::getRecipientId, userId)
                        .or(o -> o.isNull(TimeLetterDomain::getRecipientId)
                                .eq(TimeLetterDomain::getSenderId, userId)));
        if (starredOnly) {
            qw.eq(TimeLetterDomain::getStarFlag, true);
        }
        qw.orderByDesc(TimeLetterDomain::getReadAt);
        return page(mpPage(pageQuery), qw);
    }

    @Override
    public long countInFlightBySender(long senderId) {
        return count(new LambdaQueryWrapper<TimeLetterDomain>()
                .eq(TimeLetterDomain::getSenderId, senderId)
                .eq(TimeLetterDomain::isDelFlag, false)
                .eq(TimeLetterDomain::getStatus, TimeLetterStatus.PENDING.getCode()));
    }

    @Override
    public long countUnreadDeliveredForUser(long userId) {
        return count(new LambdaQueryWrapper<TimeLetterDomain>()
                .eq(TimeLetterDomain::isDelFlag, false)
                .eq(TimeLetterDomain::getStatus, TimeLetterStatus.DELIVERED.getCode())
                .and(w -> w.eq(TimeLetterDomain::getRecipientId, userId)
                        .or(o -> o.isNull(TimeLetterDomain::getRecipientId)
                                .eq(TimeLetterDomain::getSenderId, userId))));
    }

    @Override
    public long countMemorialForUser(long userId) {
        return count(new LambdaQueryWrapper<TimeLetterDomain>()
                .eq(TimeLetterDomain::isDelFlag, false)
                .eq(TimeLetterDomain::getStatus, TimeLetterStatus.READ.getCode())
                .and(w -> w.eq(TimeLetterDomain::getSenderId, userId)
                        .or().eq(TimeLetterDomain::getRecipientId, userId)
                        .or(o -> o.isNull(TimeLetterDomain::getRecipientId)
                                .eq(TimeLetterDomain::getSenderId, userId))));
    }

    @Override
    public long countTodayDeliveredForUser(long userId, LocalDateTime dayStart, LocalDateTime dayEnd) {
        return count(new LambdaQueryWrapper<TimeLetterDomain>()
                .eq(TimeLetterDomain::isDelFlag, false)
                .eq(TimeLetterDomain::getStatus, TimeLetterStatus.DELIVERED.getCode())
                .and(w -> w.eq(TimeLetterDomain::getRecipientId, userId)
                        .or(o -> o.isNull(TimeLetterDomain::getRecipientId)
                                .eq(TimeLetterDomain::getSenderId, userId)))
                .ge(TimeLetterDomain::getDeliveredAt, dayStart)
                .lt(TimeLetterDomain::getDeliveredAt, dayEnd));
    }

    @Override
    public List<TimeLetterDomain> listRecentSealedWithRecipient(long senderId, int limit) {
        return list(new LambdaQueryWrapper<TimeLetterDomain>()
                .eq(TimeLetterDomain::getSenderId, senderId)
                .eq(TimeLetterDomain::isDelFlag, false)
                .isNotNull(TimeLetterDomain::getRecipientId)
                .ne(TimeLetterDomain::getStatus, TimeLetterStatus.DRAFT.getCode())
                .orderByDesc(TimeLetterDomain::getSealedAt)
                .last("LIMIT " + Math.max(1, limit)));
    }

    @Override
    public long countSealedTodayBySender(long senderId, LocalDateTime dayStart) {
        return count(new LambdaQueryWrapper<TimeLetterDomain>()
                .eq(TimeLetterDomain::getSenderId, senderId)
                .eq(TimeLetterDomain::isDelFlag, false)
                .ge(TimeLetterDomain::getSealedAt, dayStart)
                .ne(TimeLetterDomain::getStatus, TimeLetterStatus.DRAFT.getCode())
                .ne(TimeLetterDomain::getStatus, TimeLetterStatus.CANCELLED.getCode()));
    }

    @Override
    public long countSealedToRecipientSince(long senderId, long recipientId, LocalDateTime since) {
        return count(new LambdaQueryWrapper<TimeLetterDomain>()
                .eq(TimeLetterDomain::getSenderId, senderId)
                .eq(TimeLetterDomain::getRecipientId, recipientId)
                .eq(TimeLetterDomain::isDelFlag, false)
                .ge(TimeLetterDomain::getSealedAt, since)
                .ne(TimeLetterDomain::getStatus, TimeLetterStatus.DRAFT.getCode())
                .ne(TimeLetterDomain::getStatus, TimeLetterStatus.CANCELLED.getCode()));
    }

    @Override
    public long countOwnedNonDraft(long userId) {
        return count(new LambdaQueryWrapper<TimeLetterDomain>()
                .eq(TimeLetterDomain::getSenderId, userId)
                .eq(TimeLetterDomain::isDelFlag, false)
                .ne(TimeLetterDomain::getStatus, TimeLetterStatus.DRAFT.getCode()));
    }

    @Override
    public List<TimeLetterDomain> listPendingForDelivery(int limit) {
        return list(new LambdaQueryWrapper<TimeLetterDomain>()
                .eq(TimeLetterDomain::isDelFlag, false)
                .eq(TimeLetterDomain::getStatus, TimeLetterStatus.PENDING.getCode())
                .orderByAsc(TimeLetterDomain::getDeliveryDate)
                .last("LIMIT " + Math.max(1, limit)));
    }

    @Override
    public boolean markDelivered(long letterId, LocalDateTime at) {
        return update(new LambdaUpdateWrapper<TimeLetterDomain>()
                .eq(TimeLetterDomain::getId, letterId)
                .eq(TimeLetterDomain::isDelFlag, false)
                .eq(TimeLetterDomain::getStatus, TimeLetterStatus.PENDING.getCode())
                .set(TimeLetterDomain::getStatus, TimeLetterStatus.DELIVERED.getCode())
                .set(TimeLetterDomain::getDeliveredAt, at)
                .set(TimeLetterDomain::getUpdatedAt, at)
                .set(TimeLetterDomain::getUpdatedBy, 0L));
    }

    @Override
    public boolean markFailed(long letterId, String reason, LocalDateTime at) {
        return update(new LambdaUpdateWrapper<TimeLetterDomain>()
                .eq(TimeLetterDomain::getId, letterId)
                .eq(TimeLetterDomain::isDelFlag, false)
                .eq(TimeLetterDomain::getStatus, TimeLetterStatus.PENDING.getCode())
                .set(TimeLetterDomain::getStatus, TimeLetterStatus.FAILED.getCode())
                .set(TimeLetterDomain::getFailReason, reason)
                .set(TimeLetterDomain::getUpdatedAt, at)
                .set(TimeLetterDomain::getUpdatedBy, 0L));
    }

    @Override
    public Page<TimeLetterDomain> pageForAdmin(PageQuery pageQuery, Long senderId, Long recipientId, Integer status) {
        LambdaQueryWrapper<TimeLetterDomain> qw = new LambdaQueryWrapper<TimeLetterDomain>()
                .eq(TimeLetterDomain::isDelFlag, false)
                .orderByDesc(TimeLetterDomain::getCreatedAt);
        if (senderId != null) {
            qw.eq(TimeLetterDomain::getSenderId, senderId);
        }
        if (recipientId != null) {
            qw.eq(TimeLetterDomain::getRecipientId, recipientId);
        }
        if (status != null) {
            qw.eq(TimeLetterDomain::getStatus, status);
        }
        return page(PageQueryNormalize.mpPage(pageQuery, PageQueryNormalize.ADMIN_MAX_SIZE), qw);
    }

}
