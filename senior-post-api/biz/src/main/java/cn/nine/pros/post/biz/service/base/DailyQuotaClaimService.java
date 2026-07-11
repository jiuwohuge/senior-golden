package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.DailyQuotaClaimDomain;
import com.baomidou.mybatisplus.extension.service.IService;

import java.time.LocalDate;

/**
 * 每日额度领取。
 */
public interface DailyQuotaClaimService extends IService<DailyQuotaClaimDomain> {

    /** 是否已领取指定日额度。 */
    boolean hasClaimed(long userId, LocalDate claimDate);

    /** 查询指定日领取记录；未领取返回 null。 */
    DailyQuotaClaimDomain findClaim(long userId, LocalDate claimDate);

    /**
     * 幂等领取：已存在则返回已有记录，否则新建。
     */
    DailyQuotaClaimDomain claim(long userId, LocalDate claimDate, int quotaAmount, long actorId);

    /**
     * 管理端调整当日额度上限（quota_amount）；无记录则先创建再更新。
     */
    DailyQuotaClaimDomain upsertQuotaAmount(long userId, LocalDate claimDate, int quotaAmount, long actorId);
}
