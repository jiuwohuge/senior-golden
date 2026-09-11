package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.VipSubscriptionDomain;
import com.baomidou.mybatisplus.extension.service.IService;
import cn.nine.pros.post.client.model.db.VipSubscriptionDTO;

import java.time.LocalDateTime;
import java.util.List;

/**
 * VIP订阅记录表 Service
 *
 * @author Administrator
 */
public interface VipSubscriptionService extends IService<VipSubscriptionDomain> {

    void upsert(VipSubscriptionDTO vipSubscriptionDTO);

    VipSubscriptionDTO findById(Long id);

    void delByIds(List<Long> ids);

    long countActive();

    /** 用户最新一条未删除订阅（按 updated_at / end_at 倒序）。 */
    VipSubscriptionDomain findLatestForUser(long userId);

    /** 用户当前有效订阅：status=1、end_at &gt; now、未删除（按 end_at / updated_at 倒序）。 */
    VipSubscriptionDomain findLatestActiveForUser(long userId);

    /** 按 purchase_token 查找未删除订阅。 */
    VipSubscriptionDomain findByPurchaseToken(String purchaseToken);

    /**
     * 按 purchase_token 幂等写入/刷新 Play（或 test/admin）订阅行。
     *
     * @return 持久化后的行
     */
    VipSubscriptionDomain upsertSubscription(
            long userId,
            String productId,
            String purchaseToken,
            String orderId,
            String packageName,
            boolean isTrial,
            String source,
            LocalDateTime startAt,
            LocalDateTime endAt,
            int status,
            LocalDateTime acknowledgedAt,
            long actorId);

    /** 将 end_at &lt;= now 且 status=1 的行标为过期(2)，返回影响行数。 */
    int expirePastDue(LocalDateTime now);

    /** 将指定订阅行标为过期（仅该行）。 */
    void markExpired(long subscriptionId, long actorId);

    /**
     * 将用户当前有效订阅标为过期（test-override none / 清权益）。
     */
    void expireActiveForUser(long userId, long actorId);

    /**
     * 软删用户全部订阅行（test-override none：回到 state=none）。
     */
    void softDeleteAllForUser(long userId, long actorId);
}
