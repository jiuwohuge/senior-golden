package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.pros.post.biz.mapper.AiAssistUsageMapper;
import cn.nine.pros.post.biz.model.domain.AiAssistUsageDomain;
import cn.nine.pros.post.biz.service.base.AiAssistUsageService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;

import java.time.LocalDate;

@Slf4j
@Service
public class AiAssistUsageServiceImpl extends ServiceImpl<AiAssistUsageMapper, AiAssistUsageDomain>
        implements AiAssistUsageService {

    @Override
    public AiAssistUsageDomain findOrCreateWeek(long userId, LocalDate weekStart, long actorId) {
        AiAssistUsageDomain existing = findWeek(userId, weekStart);
        if (existing != null) {
            return existing;
        }
        AiAssistUsageDomain row = new AiAssistUsageDomain();
        row.setUserId(userId);
        row.setWeekStart(weekStart);
        row.setUseCount(0);
        row.initAudit(actorId);
        try {
            save(row);
            log.debug("ai assist usage week created, userId={}, weekStart={}", userId, weekStart);
            return row;
        } catch (DuplicateKeyException e) {
            log.debug("ai assist usage week race, reuse, userId={}, weekStart={}", userId, weekStart);
            return findWeek(userId, weekStart);
        }
    }

    @Override
    public int incrementUse(long userId, LocalDate weekStart, long actorId) {
        AiAssistUsageDomain row = findOrCreateWeek(userId, weekStart, actorId);
        if (row == null) {
            log.warn("ai assist usage increment skipped: row missing, userId={}, weekStart={}", userId, weekStart);
            return 0;
        }
        int next = (row.getUseCount() == null ? 0 : row.getUseCount()) + 1;
        row.setUseCount(next);
        row.updateAudit(actorId);
        updateById(row);
        log.info("ai assist usage incremented, userId={}, weekStart={}, useCount={}", userId, weekStart, next);
        return next;
    }

    @Override
    public int getUseCount(long userId, LocalDate weekStart) {
        AiAssistUsageDomain row = findWeek(userId, weekStart);
        if (row == null || row.getUseCount() == null) {
            return 0;
        }
        return row.getUseCount();
    }

    private AiAssistUsageDomain findWeek(long userId, LocalDate weekStart) {
        if (weekStart == null) {
            return null;
        }
        return getOne(new LambdaQueryWrapper<AiAssistUsageDomain>()
                .eq(AiAssistUsageDomain::getUserId, userId)
                .eq(AiAssistUsageDomain::getWeekStart, weekStart)
                .eq(AiAssistUsageDomain::isDelFlag, false)
                .last("LIMIT 1"));
    }
}
