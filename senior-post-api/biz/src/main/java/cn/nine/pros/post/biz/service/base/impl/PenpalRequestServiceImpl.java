package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.pros.post.biz.mapper.PenpalRequestMapper;
import cn.nine.pros.post.biz.model.domain.PenpalRequestDomain;
import cn.nine.pros.post.biz.service.base.PenpalRequestService;
import cn.nine.pros.post.client.common.enums.PenpalRequestStatus;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class PenpalRequestServiceImpl extends ServiceImpl<PenpalRequestMapper, PenpalRequestDomain>
        implements PenpalRequestService {

    @Override
    public PenpalRequestDomain findPendingBetween(long userIdA, long userIdB) {
        PenpalRequestDomain ab = findPendingDirected(userIdA, userIdB);
        if (ab != null) {
            return ab;
        }
        return findPendingDirected(userIdB, userIdA);
    }

    @Override
    public List<PenpalRequestDomain> listIncomingPending(long targetUserId, int limit) {
        return list(new LambdaQueryWrapper<PenpalRequestDomain>()
                .eq(PenpalRequestDomain::getTargetId, targetUserId)
                .eq(PenpalRequestDomain::getStatus, PenpalRequestStatus.PENDING.getCode())
                .eq(PenpalRequestDomain::isDelFlag, false)
                .orderByDesc(PenpalRequestDomain::getCreatedAt)
                .last("LIMIT " + Math.max(1, limit)));
    }

    @Override
    public boolean markAccepted(long requestId, long actorUserId) {
        return update(null, new LambdaUpdateWrapper<PenpalRequestDomain>()
                .eq(PenpalRequestDomain::getId, requestId)
                .eq(PenpalRequestDomain::getStatus, PenpalRequestStatus.PENDING.getCode())
                .eq(PenpalRequestDomain::isDelFlag, false)
                .set(PenpalRequestDomain::getStatus, PenpalRequestStatus.ACCEPTED.getCode())
                .set(PenpalRequestDomain::getUpdatedAt, LocalDateTime.now())
                .set(PenpalRequestDomain::getUpdatedBy, actorUserId));
    }

    @Override
    public boolean markIgnored(long requestId, long actorUserId) {
        return update(null, new LambdaUpdateWrapper<PenpalRequestDomain>()
                .eq(PenpalRequestDomain::getId, requestId)
                .eq(PenpalRequestDomain::getStatus, PenpalRequestStatus.PENDING.getCode())
                .eq(PenpalRequestDomain::isDelFlag, false)
                .set(PenpalRequestDomain::getStatus, PenpalRequestStatus.IGNORED.getCode())
                .set(PenpalRequestDomain::getUpdatedAt, LocalDateTime.now())
                .set(PenpalRequestDomain::getUpdatedBy, actorUserId));
    }

    @Override
    public boolean existsPendingBetween(long userIdA, long userIdB) {
        return findPendingBetween(userIdA, userIdB) != null;
    }

    private PenpalRequestDomain findPendingDirected(long requesterId, long targetId) {
        return getOne(new LambdaQueryWrapper<PenpalRequestDomain>()
                .eq(PenpalRequestDomain::getRequesterId, requesterId)
                .eq(PenpalRequestDomain::getTargetId, targetId)
                .eq(PenpalRequestDomain::getStatus, PenpalRequestStatus.PENDING.getCode())
                .eq(PenpalRequestDomain::isDelFlag, false)
                .last("LIMIT 1"));
    }
}
