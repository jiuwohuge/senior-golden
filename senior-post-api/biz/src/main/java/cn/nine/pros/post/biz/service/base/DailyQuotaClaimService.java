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

    /**
     * 幂等领取：已存在则返回已有记录，否则新建。
     */
    DailyQuotaClaimDomain claim(long userId, LocalDate claimDate, int quotaAmount, long actorId);
}
