package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.AiAssistUsageDomain;
import com.baomidou.mybatisplus.extension.service.IService;

import java.time.LocalDate;

/**
 * AI 助手周用量 Base Service。
 */
public interface AiAssistUsageService extends IService<AiAssistUsageDomain> {

    /**
     * 查找或创建当周用量行（use_count=0）。
     */
    AiAssistUsageDomain findOrCreateWeek(long userId, LocalDate weekStart, long actorId);

    /**
     * 当周用量 +1，返回新的 use_count。
     */
    int incrementUse(long userId, LocalDate weekStart, long actorId);

    /**
     * 读取当周已用次数；无行返回 0。
     */
    int getUseCount(long userId, LocalDate weekStart);
}
