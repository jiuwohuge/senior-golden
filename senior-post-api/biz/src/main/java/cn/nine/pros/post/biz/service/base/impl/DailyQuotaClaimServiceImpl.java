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
        return findClaim(userId, claimDate) != null;
    }

    @Override
    public DailyQuotaClaimDomain findClaim(long userId, LocalDate claimDate) {
        if (claimDate == null) {
            return null;
        }
        return getOne(new LambdaQueryWrapper<DailyQuotaClaimDomain>()
                .eq(DailyQuotaClaimDomain::getUserId, userId)
                .eq(DailyQuotaClaimDomain::getClaimDate, claimDate)
                .eq(DailyQuotaClaimDomain::isDelFlag, false)
                .last("LIMIT 1"));
    }

    @Override
    public DailyQuotaClaimDomain claim(long userId, LocalDate claimDate, int quotaAmount, long actorId) {
        DailyQuotaClaimDomain existing = findClaim(userId, claimDate);
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
            return findClaim(userId, claimDate);
        }
    }

    @Override
    public DailyQuotaClaimDomain upsertQuotaAmount(long userId, LocalDate claimDate, int quotaAmount, long actorId) {
        DailyQuotaClaimDomain existing = findClaim(userId, claimDate);
        if (existing == null) {
            return claim(userId, claimDate, quotaAmount, actorId);
        }
        existing.setQuotaAmount(quotaAmount);
        existing.updateAudit(actorId);
        updateById(existing);
        log.info("daily quota amount updated, userId={}, date={}, amount={}", userId, claimDate, quotaAmount);
        return existing;
    }
}
