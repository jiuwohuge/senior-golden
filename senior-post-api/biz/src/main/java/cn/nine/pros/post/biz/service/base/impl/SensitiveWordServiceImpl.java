package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.nine.pros.post.biz.mapper.SensitiveWordMapper;
import cn.nine.pros.post.biz.model.domain.SensitiveWordDomain;
import cn.nine.pros.post.biz.model.mapstruct.SensitiveWordMapstruct;
import cn.nine.pros.post.biz.service.base.SensitiveWordService;
import cn.nine.pros.post.client.model.db.SensitiveWordDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Locale;
import java.util.stream.Collectors;

/**
 * 敏感词库表 ServiceImpl
 *
 * @author Administrator
 */
@Service
public class SensitiveWordServiceImpl extends ServiceImpl<SensitiveWordMapper, SensitiveWordDomain>
        implements SensitiveWordService {

    private static final long WORD_CACHE_TTL_MS = 60_000L;

    @Autowired
    private SensitiveWordMapstruct sensitiveWordMapstruct;

    private volatile List<String> cachedActiveWords;
    private volatile long cachedActiveWordsAt;

    @Override
    public void upsert(SensitiveWordDTO sensitiveWordDTO) {
        Integer id = sensitiveWordDTO.getId();
        if (id == null) {
            SensitiveWordDomain domain = sensitiveWordMapstruct.toDomain(sensitiveWordDTO);
            domain.initAudit(MyRequestContextHolder.userId());
            save(domain);
            evictWordCache();
            return;
        }
        SensitiveWordDomain domain = sensitiveWordMapstruct.toDomain(sensitiveWordDTO);
        domain.setId(id);
        domain.setUpdatedAt(LocalDateTime.now());
        domain.setUpdatedBy(MyRequestContextHolder.userId());
        updateById(domain);
        evictWordCache();
    }

    @Override
    public SensitiveWordDTO findById(Integer id) {
        return sensitiveWordMapstruct.toDTO(getById(id));
    }

    @Override
    public void delByIds(List<Integer> ids) {
        SensitiveWordDomain sensitiveWordDomain = new SensitiveWordDomain();
        sensitiveWordDomain.setDelFlag(true);
        sensitiveWordDomain.setUpdatedAt(LocalDateTime.now());
        update(sensitiveWordDomain, new LambdaQueryWrapper<SensitiveWordDomain>()
                .in(SensitiveWordDomain::getId, ids));
        evictWordCache();
    }

    @Override
    public void assertPlainTextAllowed(String text) {
        if (!StringUtils.hasText(text)) {
            return;
        }
        String haystack = text.toLowerCase(Locale.ROOT);
        for (String w : activeWordsSnapshot()) {
            if (!StringUtils.hasText(w)) {
                continue;
            }
            String needle = w.trim().toLowerCase(Locale.ROOT);
            if (needle.isEmpty()) {
                continue;
            }
            if (haystack.contains(needle)) {
                throw new BadRequestException("内容包含不当词汇，请修改后重试");
            }
        }
    }

    private void evictWordCache() {
        cachedActiveWords = null;
    }

    private List<String> activeWordsSnapshot() {
        long now = System.currentTimeMillis();
        List<String> snap = cachedActiveWords;
        if (snap != null && now - cachedActiveWordsAt < WORD_CACHE_TTL_MS) {
            return snap;
        }
        synchronized (this) {
            snap = cachedActiveWords;
            if (snap != null && now - cachedActiveWordsAt < WORD_CACHE_TTL_MS) {
                return snap;
            }
            List<SensitiveWordDomain> rows = list(new LambdaQueryWrapper<SensitiveWordDomain>()
                    .eq(SensitiveWordDomain::isDelFlag, false)
                    .select(SensitiveWordDomain::getId, SensitiveWordDomain::getWord));
            snap = rows.stream()
                    .map(SensitiveWordDomain::getWord)
                    .filter(StringUtils::hasText)
                    .map(String::trim)
                    .distinct()
                    .collect(Collectors.toList());
            cachedActiveWords = snap;
            cachedActiveWordsAt = System.currentTimeMillis();
            return snap;
        }
    }

}