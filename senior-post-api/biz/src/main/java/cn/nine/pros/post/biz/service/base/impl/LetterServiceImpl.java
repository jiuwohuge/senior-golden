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
 * 信件表ServiceImpl
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
    public long countOutboundInTransit(long fromUserId) {
        return count(new LambdaQueryWrapper<LetterDomain>()
                .eq(LetterDomain::isDelFlag, false)
                .eq(LetterDomain::getFromUserId, fromUserId)
                .ne(LetterDomain::getAuditStatus, LetterAuditStatus.REJECTED.getCode())
                .in(LetterDomain::getStatus,
                        LetterBizStatus.PENDING.getCode(),
                        LetterBizStatus.MATCHED.getCode(),
                        LetterBizStatus.DELIVERING.getCode()));
    }

    @Override
    public long countByToUserAndStatus(long toUserId, int status) {
        return count(new LambdaQueryWrapper<LetterDomain>()
                .eq(LetterDomain::isDelFlag, false)
                .eq(LetterDomain::getToUserId, toUserId)
                .eq(LetterDomain::getStatus, status));
    }

    @Override
    public long countInboundInTransit(long toUserId) {
        return count(new LambdaQueryWrapper<LetterDomain>()
                .eq(LetterDomain::isDelFlag, false)
                .eq(LetterDomain::getToUserId, toUserId)
                .ne(LetterDomain::getAuditStatus, LetterAuditStatus.REJECTED.getCode())
                .eq(LetterDomain::getStatus, LetterBizStatus.DELIVERING.getCode()));
    }

    @Override
    public long countUnreadDeliveredForToUser(long toUserId) {
        return count(new LambdaQueryWrapper<LetterDomain>()
                .eq(LetterDomain::isDelFlag, false)
                .eq(LetterDomain::getToUserId, toUserId)
                .eq(LetterDomain::getStatus, LetterBizStatus.DELIVERED.getCode())
                .ne(LetterDomain::getAuditStatus, LetterAuditStatus.REJECTED.getCode())
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
    public boolean forceAdminDeliver(long letterId, LocalDateTime at, Long adminUserId) {
        Long auditBy = adminUserId != null ? adminUserId : 0L;
        return update(new LambdaUpdateWrapper<LetterDomain>()
                .eq(LetterDomain::getId, letterId)
                .eq(LetterDomain::isDelFlag, false)
                .isNotNull(LetterDomain::getToUserId)
                .in(LetterDomain::getStatus,
                        LetterBizStatus.MATCHED.getCode(),
                        LetterBizStatus.DELIVERING.getCode())
                .set(LetterDomain::getStatus, LetterBizStatus.DELIVERED.getCode())
                .set(LetterDomain::getActualArrivalTime, at)
                .set(LetterDomain::getUpdatedAt, at)
                .set(LetterDomain::getUpdatedBy, auditBy));
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
    public long countWaitingMatch() {
        return count(new LambdaQueryWrapper<LetterDomain>()
                .eq(LetterDomain::isDelFlag, false)
                .eq(LetterDomain::getMode, cn.nine.pros.post.client.common.enums.LetterMode.POST_OFFICE.getCode())
                .eq(LetterDomain::getStatus, LetterBizStatus.PENDING.getCode())
                .isNull(LetterDomain::getToUserId));
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
            cn.nine.commons.data.page.PageQuery pageQuery,
            Integer auditStatus, Integer mode, Integer status,
            Long fromUserId, Long toUserId, String keyword,
            LocalDateTime createdFrom, LocalDateTime createdTo) {
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
        if (status != null) {
            qw.eq(LetterDomain::getStatus, status);
        }
        if (fromUserId != null) {
            qw.eq(LetterDomain::getFromUserId, fromUserId);
        }
        if (toUserId != null) {
            qw.eq(LetterDomain::getToUserId, toUserId);
        }
        if (keyword != null && !keyword.isBlank()) {
            qw.like(LetterDomain::getContent, keyword.trim());
        }
        if (createdFrom != null) {
            qw.ge(LetterDomain::getCreatedAt, createdFrom);
        }
        if (createdTo != null) {
            qw.le(LetterDomain::getCreatedAt, createdTo);
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
    public long countRepliesSentByUser(long userId) {
        return count(new LambdaQueryWrapper<LetterDomain>()
                .eq(LetterDomain::isDelFlag, false)
                .eq(LetterDomain::getFromUserId, userId)
                .isNotNull(LetterDomain::getParentLetterId));
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
    public List<LetterDomain> listOutboundInTransit(long fromUserId, int limit) {
        return list(new LambdaQueryWrapper<LetterDomain>()
                .eq(LetterDomain::isDelFlag, false)
                .eq(LetterDomain::getFromUserId, fromUserId)
                .ne(LetterDomain::getAuditStatus, LetterAuditStatus.REJECTED.getCode())
                .in(LetterDomain::getStatus,
                        LetterBizStatus.PENDING.getCode(),
                        LetterBizStatus.MATCHED.getCode(),
                        LetterBizStatus.DELIVERING.getCode())
                .orderByDesc(LetterDomain::getUpdatedAt)
                .last("LIMIT " + Math.max(1, limit)));
    }

    @Override
    public List<LetterDomain> listInboundDelivering(long toUserId, int limit) {
        return list(new LambdaQueryWrapper<LetterDomain>()
                .eq(LetterDomain::isDelFlag, false)
                .eq(LetterDomain::getToUserId, toUserId)
                .ne(LetterDomain::getAuditStatus, LetterAuditStatus.REJECTED.getCode())
                .eq(LetterDomain::getStatus, LetterBizStatus.DELIVERING.getCode())
                .orderByDesc(LetterDomain::getUpdatedAt)
                .last("LIMIT " + Math.max(1, limit)));
    }

    @Override
    public List<LetterDomain> listUnreadDelivered(long toUserId, int limit) {
        return list(new LambdaQueryWrapper<LetterDomain>()
                .eq(LetterDomain::isDelFlag, false)
                .eq(LetterDomain::getToUserId, toUserId)
                .ne(LetterDomain::getAuditStatus, LetterAuditStatus.REJECTED.getCode())
                .eq(LetterDomain::getStatus, LetterBizStatus.DELIVERED.getCode())
                .isNull(LetterDomain::getRecipientReadAt)
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

    @Override
    public List<LetterDomain> listDeliveredForExport(
            long userId, Long peerUserId, LocalDateTime from, LocalDateTime to, int limit) {
        LambdaQueryWrapper<LetterDomain> qw = new LambdaQueryWrapper<LetterDomain>()
                .eq(LetterDomain::isDelFlag, false)
                .eq(LetterDomain::getStatus, LetterBizStatus.DELIVERED.getCode())
                .ne(LetterDomain::getAuditStatus, LetterAuditStatus.REJECTED.getCode())
                .and(w -> w.eq(LetterDomain::getFromUserId, userId)
                        .or()
                        .eq(LetterDomain::getToUserId, userId))
                .orderByAsc(LetterDomain::getCreatedAt)
                .last("LIMIT " + Math.max(1, limit));
        if (peerUserId != null) {
            qw.and(w -> w
                    .nested(n -> n.eq(LetterDomain::getFromUserId, userId)
                            .eq(LetterDomain::getToUserId, peerUserId))
                    .or()
                    .nested(n -> n.eq(LetterDomain::getFromUserId, peerUserId)
                            .eq(LetterDomain::getToUserId, userId)));
        }
        if (from != null) {
            qw.ge(LetterDomain::getCreatedAt, from);
        }
        if (to != null) {
            qw.le(LetterDomain::getCreatedAt, to);
        }
        return list(qw);
    }

    @Override
    public long countCreatedBetween(LocalDateTime start, LocalDateTime end) {
        LambdaQueryWrapper<LetterDomain> qw = new LambdaQueryWrapper<LetterDomain>()
                .eq(LetterDomain::isDelFlag, false);
        if (start != null) {
            qw.ge(LetterDomain::getCreatedAt, start);
        }
        if (end != null) {
            qw.lt(LetterDomain::getCreatedAt, end);
        }
        return count(qw);
    }

    @Override
    public long countInTransit() {
        return count(new LambdaQueryWrapper<LetterDomain>()
                .eq(LetterDomain::isDelFlag, false)
                .in(LetterDomain::getStatus,
                        LetterBizStatus.DELIVERING.getCode(),
                        LetterBizStatus.MATCHED.getCode()));
    }

    @Override
    public long countPendingAudit() {
        return count(new LambdaQueryWrapper<LetterDomain>()
                .eq(LetterDomain::isDelFlag, false)
                .eq(LetterDomain::getAuditStatus, LetterAuditStatus.PENDING_REVIEW.getCode()));
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
