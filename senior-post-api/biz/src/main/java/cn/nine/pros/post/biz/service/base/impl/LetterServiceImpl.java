package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.nine.pros.post.biz.mapper.LetterMapper;
import cn.nine.pros.post.biz.model.domain.LetterDomain;
import cn.nine.pros.post.biz.model.mapstruct.LetterMapstruct;
import cn.nine.pros.post.biz.service.base.LetterService;
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
                .eq(LetterDomain::getStatus, LetterBizStatus.DELIVERING.getCode())
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
}
