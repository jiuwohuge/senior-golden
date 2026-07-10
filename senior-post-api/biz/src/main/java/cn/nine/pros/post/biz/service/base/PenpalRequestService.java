package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.PenpalRequestDomain;
import com.baomidou.mybatisplus.extension.service.IService;

import java.util.List;

public interface PenpalRequestService extends IService<PenpalRequestDomain> {

    PenpalRequestDomain findPendingBetween(long userIdA, long userIdB);

    List<PenpalRequestDomain> listIncomingPending(long targetUserId, int limit);

    boolean markAccepted(long requestId, long actorUserId);

    boolean markIgnored(long requestId, long actorUserId);

    /** 双方之间是否存在进行中的申请（任一方向）。 */
    boolean existsPendingBetween(long userIdA, long userIdB);
}
