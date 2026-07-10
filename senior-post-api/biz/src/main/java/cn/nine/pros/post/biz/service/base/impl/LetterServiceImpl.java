package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.nine.pros.post.biz.mapper.LetterMapper;
import cn.nine.pros.post.biz.model.domain.LetterDomain;
import cn.nine.pros.post.biz.model.mapstruct.LetterMapstruct;
import cn.nine.pros.post.biz.service.base.LetterService;
import cn.nine.pros.post.client.common.enums.LetterAuditStatus;
import cn.nine.pros.post.client.common.enums.LetterBizStatus;
import cn.nine.pros.post.client.model.db.LetterDTO;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 信件表（挂号信/平邮）ServiceImpl
 */
@Service
public class LetterServiceImpl extends ServiceImpl<LetterMapper, LetterDomain>
        implements LetterService {

    @Autowired
    private LetterMapstruct letterMapstruct;

    @Override
    public void upsert(LetterDTO letterDTO) {
        Long id = letterDTO.getId();
        if (id == null) {
            LetterDomain domain = letterMapstruct.toDomain(letterDTO);
            domain.initAudit(MyRequestContextHolder.userId());
            save(domain);
            return;
        }
        LetterDomain domain = letterMapstruct.toDomain(letterDTO);
        domain.setId(id);
        domain.setUpdatedAt(LocalDateTime.now());
        domain.setUpdatedBy(MyRequestContextHolder.userId());
        updateById(domain);
    }

    @Override
    public LetterDTO findById(Long id) {
        return letterMapstruct.toDTO(getById(id));
    }

    @Override
    public void delByIds(List<Long> ids) {
        LetterDomain letterDomain = new LetterDomain();
        letterDomain.setDelFlag(true);
        letterDomain.setUpdatedAt(LocalDateTime.now());
        update(letterDomain, new LambdaQueryWrapper<LetterDomain>()
                .in(LetterDomain::getId, ids));
    }

    @Override
    public long countPeerLetterReferencingContent(long viewerUserId, long ownerUserId, List<String> variants) {
        return getBaseMapper().countPeerLetterReferencingContent(viewerUserId, ownerUserId, variants);
    }

    @Override
    public long countSentByFromUserBetween(long fromUserId, LocalDateTime start, LocalDateTime end) {
        return count(new LambdaQueryWrapper<LetterDomain>()
                .eq(LetterDomain::isDelFlag, false)
                .eq(LetterDomain::getFromUserId, fromUserId)
                .ge(LetterDomain::getCreatedAt, start)
                .le(LetterDomain::getCreatedAt, end));
    }

    @Override
    public long countByFromUserAndStatus(long fromUserId, int status) {
        return count(new LambdaQueryWrapper<LetterDomain>()
                .eq(LetterDomain::isDelFlag, false)
                .eq(LetterDomain::getFromUserId, fromUserId)
                .eq(LetterDomain::getStatus, status));
    }

    @Override
    public long countByToUserAndStatus(long toUserId, int status) {
        return count(new LambdaQueryWrapper<LetterDomain>()
                .eq(LetterDomain::isDelFlag, false)
                .eq(LetterDomain::getToUserId, toUserId)
                .eq(LetterDomain::getStatus, status));
    }

    @Override
    public long countUnreadDeliveredForToUser(long toUserId) {
        return count(new LambdaQueryWrapper<LetterDomain>()
                .eq(LetterDomain::isDelFlag, false)
                .eq(LetterDomain::getToUserId, toUserId)
                .eq(LetterDomain::getStatus, LetterBizStatus.DELIVERED.getCode())
                .isNull(LetterDomain::getRecipientReadAt));
    }

    @Override
    public long countActive() {
        return count(new LambdaQueryWrapper<LetterDomain>()
                .eq(LetterDomain::isDelFlag, false));
    }

    @Override
    public List<LetterDomain> listMailboxForUser(long userId, LocalDateTime since, int limit) {
        LambdaQueryWrapper<LetterDomain> q = new LambdaQueryWrapper<LetterDomain>()
                .eq(LetterDomain::isDelFlag, false)
                .and(w -> w.eq(LetterDomain::getFromUserId, userId).or().eq(LetterDomain::getToUserId, userId));
        if (since != null) {
            q.apply("COALESCE(updated_at, created_at) > {0}", since);
        }
        q.orderByDesc(LetterDomain::getUpdatedAt).last("LIMIT " + Math.max(1, limit));
        return list(q);
    }

    @Override
    public List<LetterDomain> listRecentByFromUser(long fromUserId, int limit) {
        return list(new LambdaQueryWrapper<LetterDomain>()
                .eq(LetterDomain::getFromUserId, fromUserId)
                .eq(LetterDomain::isDelFlag, false)
                .orderByDesc(LetterDomain::getId)
                .last("LIMIT " + Math.max(1, limit)));
    }

    @Override
    public boolean markRecipientRead(long letterId, long toUserId, LocalDateTime at) {
        return update(new LambdaUpdateWrapper<LetterDomain>()
                .eq(LetterDomain::getId, letterId)
                .eq(LetterDomain::isDelFlag, false)
                .eq(LetterDomain::getToUserId, toUserId)
                .isNull(LetterDomain::getRecipientReadAt)
                .set(LetterDomain::getRecipientReadAt, at)
                .set(LetterDomain::getUpdatedAt, at)
                .set(LetterDomain::getUpdatedBy, toUserId));
    }

    @Override
    public boolean markEarlyOpenedAndDelivered(long letterId, long toUserId, LocalDateTime at) {
        return update(new LambdaUpdateWrapper<LetterDomain>()
                .eq(LetterDomain::getId, letterId)
                .eq(LetterDomain::isDelFlag, false)
                .eq(LetterDomain::getStatus, LetterBizStatus.DELIVERING.getCode())
                .eq(LetterDomain::getToUserId, toUserId)
                .isNull(LetterDomain::getRecipientEarlyOpenAt)
                .set(LetterDomain::getRecipientEarlyOpenAt, at)
                .set(LetterDomain::getStatus, LetterBizStatus.DELIVERED.getCode())
                .set(LetterDomain::getActualArrivalTime, at)
                .set(LetterDomain::getRecipientReadAt, at)
                .set(LetterDomain::getUpdatedAt, at)
                .set(LetterDomain::getUpdatedBy, toUserId));
    }

    @Override
    public List<LetterDomain> listDueDelivering(LocalDateTime now, int limit) {
        return list(new LambdaQueryWrapper<LetterDomain>()
                .eq(LetterDomain::isDelFlag, false)
                .eq(LetterDomain::getStatus, LetterBizStatus.DELIVERING.getCode())
                .isNotNull(LetterDomain::getExpectedArrivalTime)
                .le(LetterDomain::getExpectedArrivalTime, now)
                .isNotNull(LetterDomain::getToUserId)
                .orderByAsc(LetterDomain::getExpectedArrivalTime)
                .last("LIMIT " + Math.max(1, limit)));
    }

    @Override
    public boolean abortDeliveryRejected(long letterId, LocalDateTime at) {
        return update(new LambdaUpdateWrapper<LetterDomain>()
                .eq(LetterDomain::getId, letterId)
                .eq(LetterDomain::isDelFlag, false)
                .in(LetterDomain::getStatus,
                        LetterBizStatus.DELIVERING.getCode(),
                        LetterBizStatus.MATCHED.getCode())
                .set(LetterDomain::getStatus, LetterBizStatus.PENDING.getCode())
                .set(LetterDomain::getUpdatedAt, at)
                .set(LetterDomain::getUpdatedBy, 0L));
    }

    @Override
    public boolean markDelivered(long letterId, LocalDateTime at) {
        return update(new LambdaUpdateWrapper<LetterDomain>()
                .eq(LetterDomain::getId, letterId)
                .eq(LetterDomain::isDelFlag, false)
                .eq(LetterDomain::getStatus, LetterBizStatus.DELIVERING.getCode())
                .set(LetterDomain::getStatus, LetterBizStatus.DELIVERED.getCode())
                .set(LetterDomain::getActualArrivalTime, at)
                .set(LetterDomain::getUpdatedAt, at)
                .set(LetterDomain::getUpdatedBy, 0L));
    }

    @Override
    public List<LetterDomain> listPostOfficePendingPool(int limit) {
        return list(new LambdaQueryWrapper<LetterDomain>()
                .eq(LetterDomain::isDelFlag, false)
                .eq(LetterDomain::getMode, cn.nine.pros.post.client.common.enums.LetterMode.POST_OFFICE.getCode())
                .eq(LetterDomain::getStatus, LetterBizStatus.PENDING.getCode())
                .isNull(LetterDomain::getToUserId)
                .orderByAsc(LetterDomain::getCreatedAt)
                .last("LIMIT " + Math.max(1, limit)));
    }

    @Override
    public boolean tryAssignMatch(long letterId, long toUserId, LocalDateTime matchedAt) {
        return update(new LambdaUpdateWrapper<LetterDomain>()
                .eq(LetterDomain::getId, letterId)
                .eq(LetterDomain::isDelFlag, false)
                .eq(LetterDomain::getMode, cn.nine.pros.post.client.common.enums.LetterMode.POST_OFFICE.getCode())
                .eq(LetterDomain::getStatus, LetterBizStatus.PENDING.getCode())
                .isNull(LetterDomain::getToUserId)
                .set(LetterDomain::getToUserId, toUserId)
                .set(LetterDomain::getMatchedAt, matchedAt)
                .set(LetterDomain::getStatus, LetterBizStatus.MATCHED.getCode())
                .set(LetterDomain::getUpdatedAt, matchedAt)
                .set(LetterDomain::getUpdatedBy, 0L));
    }

    @Override
    public boolean startDeliveringAfterMatch(long letterId, LocalDateTime eta, LocalDateTime now) {
        return update(new LambdaUpdateWrapper<LetterDomain>()
                .eq(LetterDomain::getId, letterId)
                .eq(LetterDomain::isDelFlag, false)
                .eq(LetterDomain::getStatus, LetterBizStatus.MATCHED.getCode())
                .isNotNull(LetterDomain::getToUserId)
                .set(LetterDomain::getStatus, LetterBizStatus.DELIVERING.getCode())
                .set(LetterDomain::getExpectedArrivalTime, eta)
                .set(LetterDomain::getUpdatedAt, now)
                .set(LetterDomain::getUpdatedBy, 0L));
    }

    @Override
    public long countInboundPostOfficeSince(long toUserId, LocalDateTime since) {
        return count(new LambdaQueryWrapper<LetterDomain>()
                .eq(LetterDomain::isDelFlag, false)
                .eq(LetterDomain::getMode, cn.nine.pros.post.client.common.enums.LetterMode.POST_OFFICE.getCode())
                .eq(LetterDomain::getToUserId, toUserId)
                .isNotNull(LetterDomain::getMatchedAt)
                .ge(LetterDomain::getMatchedAt, since));
    }

    @Override
    public long countSentQuotaByFromUserBetween(long fromUserId, LocalDateTime start, LocalDateTime end) {
        return count(new LambdaQueryWrapper<LetterDomain>()
                .eq(LetterDomain::isDelFlag, false)
                .eq(LetterDomain::getFromUserId, fromUserId)
                .ge(LetterDomain::getCreatedAt, start)
                .le(LetterDomain::getCreatedAt, end)
                .ne(LetterDomain::getAuditStatus,
                        cn.nine.pros.post.client.common.enums.LetterAuditStatus.REJECTED.getCode()));
    }

    @Override
    public boolean approveAudit(long letterId, LocalDateTime at, Long auditUserId) {
        return update(new LambdaUpdateWrapper<LetterDomain>()
                .eq(LetterDomain::getId, letterId)
                .eq(LetterDomain::isDelFlag, false)
                .ne(LetterDomain::getAuditStatus,
                        cn.nine.pros.post.client.common.enums.LetterAuditStatus.REJECTED.getCode())
                .set(LetterDomain::getAuditStatus,
                        cn.nine.pros.post.client.common.enums.LetterAuditStatus.APPROVED.getCode())
                .set(LetterDomain::getUpdatedAt, at)
                .set(LetterDomain::getUpdatedBy, auditUserId));
    }

    @Override
    public boolean rejectAudit(long letterId, LocalDateTime at, Long auditUserId) {
        return update(new LambdaUpdateWrapper<LetterDomain>()
                .eq(LetterDomain::getId, letterId)
                .eq(LetterDomain::isDelFlag, false)
                .set(LetterDomain::getAuditStatus,
                        cn.nine.pros.post.client.common.enums.LetterAuditStatus.REJECTED.getCode())
                .set(LetterDomain::getUpdatedAt, at)
                .set(LetterDomain::getUpdatedBy, auditUserId));
    }

    @Override
    public List<LetterDomain> listPendingReviewBefore(LocalDateTime createdBefore, int limit) {
        return list(new LambdaQueryWrapper<LetterDomain>()
                .eq(LetterDomain::isDelFlag, false)
                .eq(LetterDomain::getAuditStatus,
                        cn.nine.pros.post.client.common.enums.LetterAuditStatus.PENDING_REVIEW.getCode())
                .le(LetterDomain::getCreatedAt, createdBefore)
                .orderByAsc(LetterDomain::getCreatedAt)
                .last("LIMIT " + Math.max(1, limit)));
    }

    @Override
    public com.baomidou.mybatisplus.extension.plugins.pagination.Page<LetterDomain> pageForAdminAudit(
            cn.nine.commons.data.page.PageQuery pageQuery, Integer auditStatus, Integer mode) {
        long page = pageQuery.getPage() == null || pageQuery.getPage() < 1 ? 1L : pageQuery.getPage();
        long size = pageQuery.getSize() == null || pageQuery.getSize() < 1 ? 20L : pageQuery.getSize();
        LambdaQueryWrapper<LetterDomain> qw = new LambdaQueryWrapper<LetterDomain>()
                .eq(LetterDomain::isDelFlag, false)
                .orderByDesc(LetterDomain::getCreatedAt);
        if (auditStatus != null) {
            qw.eq(LetterDomain::getAuditStatus, auditStatus);
        }
        if (mode != null) {
            qw.eq(LetterDomain::getMode, mode);
        }
        return page(new com.baomidou.mybatisplus.extension.plugins.pagination.Page<>(page, size), qw);
    }

    @Override
    public long countLettersSentByUser(long userId) {
        return count(new LambdaQueryWrapper<LetterDomain>()
                .eq(LetterDomain::isDelFlag, false)
                .eq(LetterDomain::getFromUserId, userId));
    }

    @Override
    public long countExchangeBetween(long userIdA, long userIdB) {
        if (userIdA == userIdB) {
            return 0;
        }
        return count(exchangeWrapper(userIdA, userIdB));
    }

    @Override
    public boolean hasBidirectionalExchange(long userIdA, long userIdB) {
        if (userIdA == userIdB) {
            return false;
        }
        long aToB = count(exchangeDirectedWrapper(userIdA, userIdB));
        if (aToB <= 0) {
            return false;
        }
        return count(exchangeDirectedWrapper(userIdB, userIdA)) > 0;
    }

    @Override
    public long countDeliveredParticipationForUser(long userId) {
        return count(new LambdaQueryWrapper<LetterDomain>()
                .eq(LetterDomain::isDelFlag, false)
                .eq(LetterDomain::getStatus, LetterBizStatus.DELIVERED.getCode())
                .ne(LetterDomain::getAuditStatus, LetterAuditStatus.REJECTED.getCode())
                .and(w -> w.eq(LetterDomain::getFromUserId, userId).or().eq(LetterDomain::getToUserId, userId)));
    }

    @Override
    public List<LetterDomain> listReceivedForUser(long userId, int limit) {
        return list(new LambdaQueryWrapper<LetterDomain>()
                .eq(LetterDomain::isDelFlag, false)
                .eq(LetterDomain::getToUserId, userId)
                .isNotNull(LetterDomain::getFromUserId)
                .ne(LetterDomain::getAuditStatus, LetterAuditStatus.REJECTED.getCode())
                .orderByDesc(LetterDomain::getUpdatedAt)
                .last("LIMIT " + Math.max(1, limit)));
    }

    @Override
    public List<LetterDomain> listSentForUser(long userId, int limit) {
        return list(new LambdaQueryWrapper<LetterDomain>()
                .eq(LetterDomain::isDelFlag, false)
                .eq(LetterDomain::getFromUserId, userId)
                .ne(LetterDomain::getAuditStatus, LetterAuditStatus.REJECTED.getCode())
                .orderByDesc(LetterDomain::getUpdatedAt)
                .last("LIMIT " + Math.max(1, limit)));
    }

    @Override
    public List<Long> listExchangePeerIds(long viewerUserId, int limit) {
        List<LetterDomain> rows = list(new LambdaQueryWrapper<LetterDomain>()
                .eq(LetterDomain::isDelFlag, false)
                .eq(LetterDomain::getStatus, LetterBizStatus.DELIVERED.getCode())
                .ne(LetterDomain::getAuditStatus, LetterAuditStatus.REJECTED.getCode())
                .and(w -> w.eq(LetterDomain::getFromUserId, viewerUserId)
                        .or()
                        .eq(LetterDomain::getToUserId, viewerUserId))
                .orderByDesc(LetterDomain::getUpdatedAt)
                .last("LIMIT " + Math.max(50, limit * 10)));
        java.util.LinkedHashSet<Long> peers = new java.util.LinkedHashSet<>();
        for (LetterDomain row : rows) {
            if (row.getFromUserId() == null || row.getToUserId() == null) {
                continue;
            }
            long peer = row.getFromUserId().equals(viewerUserId)
                    ? row.getToUserId()
                    : row.getFromUserId();
            if (peer == viewerUserId) {
                continue;
            }
            peers.add(peer);
            if (peers.size() >= limit) {
                break;
            }
        }
        return new java.util.ArrayList<>(peers);
    }

    private static LambdaQueryWrapper<LetterDomain> exchangeWrapper(long userIdA, long userIdB) {
        return new LambdaQueryWrapper<LetterDomain>()
                .eq(LetterDomain::isDelFlag, false)
                .eq(LetterDomain::getStatus, LetterBizStatus.DELIVERED.getCode())
                .ne(LetterDomain::getAuditStatus, LetterAuditStatus.REJECTED.getCode())
                .and(w -> w
                        .nested(n -> n.eq(LetterDomain::getFromUserId, userIdA)
                                .eq(LetterDomain::getToUserId, userIdB))
                        .or()
                        .nested(n -> n.eq(LetterDomain::getFromUserId, userIdB)
                                .eq(LetterDomain::getToUserId, userIdA)));
    }

    private static LambdaQueryWrapper<LetterDomain> exchangeDirectedWrapper(long fromUserId, long toUserId) {
        return new LambdaQueryWrapper<LetterDomain>()
                .eq(LetterDomain::isDelFlag, false)
                .eq(LetterDomain::getStatus, LetterBizStatus.DELIVERED.getCode())
                .ne(LetterDomain::getAuditStatus, LetterAuditStatus.REJECTED.getCode())
                .eq(LetterDomain::getFromUserId, fromUserId)
                .eq(LetterDomain::getToUserId, toUserId);
    }

}
