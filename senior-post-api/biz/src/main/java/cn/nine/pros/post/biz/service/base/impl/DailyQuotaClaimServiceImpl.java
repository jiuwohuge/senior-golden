package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.pros.post.biz.mapper.DailyQuotaClaimMapper;
import cn.nine.pros.post.biz.model.domain.DailyQuotaClaimDomain;
import cn.nine.pros.post.biz.service.base.DailyQuotaClaimService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;

import java.time.LocalDate;

@Slf4j
@Service
public class DailyQuotaClaimServiceImpl extends ServiceImpl<DailyQuotaClaimMapper, DailyQuotaClaimDomain>
        implements DailyQuotaClaimService {

    @Override
    public boolean hasClaimed(long userId, LocalDate claimDate) {
        if (claimDate == null) {
            return false;
        }
        return count(new LambdaQueryWrapper<DailyQuotaClaimDomain>()
                .eq(DailyQuotaClaimDomain::getUserId, userId)
                .eq(DailyQuotaClaimDomain::getClaimDate, claimDate)
                .eq(DailyQuotaClaimDomain::isDelFlag, false)) > 0;
    }

    @Override
    public DailyQuotaClaimDomain claim(long userId, LocalDate claimDate, int quotaAmount, long actorId) {
        DailyQuotaClaimDomain existing = getOne(new LambdaQueryWrapper<DailyQuotaClaimDomain>()
                .eq(DailyQuotaClaimDomain::getUserId, userId)
                .eq(DailyQuotaClaimDomain::getClaimDate, claimDate)
                .eq(DailyQuotaClaimDomain::isDelFlag, false)
                .last("LIMIT 1"));
        if (existing != null) {
            return existing;
        }
        DailyQuotaClaimDomain row = new DailyQuotaClaimDomain();
        row.setUserId(userId);
        row.setClaimDate(claimDate);
        row.setQuotaAmount(quotaAmount);
        row.initAudit(actorId);
        try {
            save(row);
            log.info("daily quota claimed, userId={}, date={}, amount={}", userId, claimDate, quotaAmount);
            return row;
        } catch (DuplicateKeyException e) {
            log.info("daily quota claim race, reuse existing, userId={}, date={}", userId, claimDate);
            return getOne(new LambdaQueryWrapper<DailyQuotaClaimDomain>()
                    .eq(DailyQuotaClaimDomain::getUserId, userId)
                    .eq(DailyQuotaClaimDomain::getClaimDate, claimDate)
                    .eq(DailyQuotaClaimDomain::isDelFlag, false)
                    .last("LIMIT 1"));
        }
    }
}
