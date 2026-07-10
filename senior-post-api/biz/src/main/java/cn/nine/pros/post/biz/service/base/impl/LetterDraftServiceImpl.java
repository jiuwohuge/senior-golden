package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.pros.post.biz.mapper.LetterDraftMapper;
import cn.nine.pros.post.biz.model.domain.LetterDraftDomain;
import cn.nine.pros.post.biz.service.base.LetterDraftService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class LetterDraftServiceImpl extends ServiceImpl<LetterDraftMapper, LetterDraftDomain>
        implements LetterDraftService {

    @Override
    public List<LetterDraftDomain> listForUser(Long userId) {
        if (userId == null) {
            return List.of();
        }
        return list(new LambdaQueryWrapper<LetterDraftDomain>()
                .eq(LetterDraftDomain::getUserId, userId)
                .eq(LetterDraftDomain::isDelFlag, false)
                .orderByDesc(LetterDraftDomain::getUpdatedAt));
    }

    @Override
    public LetterDraftDomain findOwned(Long userId, Long draftId) {
        if (userId == null || draftId == null) {
            return null;
        }
        return getOne(new LambdaQueryWrapper<LetterDraftDomain>()
                .eq(LetterDraftDomain::getId, draftId)
                .eq(LetterDraftDomain::getUserId, userId)
                .eq(LetterDraftDomain::isDelFlag, false)
                .last("LIMIT 1"));
    }

    @Override
    public LetterDraftDomain saveOwned(LetterDraftDomain draft, Long actorId) {
        if (draft == null || draft.getUserId() == null) {
            return null;
        }
        Long auditUserId = actorId != null ? actorId : draft.getUserId();
        if (draft.getId() == null) {
            draft.initAudit(auditUserId);
            save(draft);
            return draft;
        }
        LetterDraftDomain owned = findOwned(draft.getUserId(), draft.getId());
        if (owned == null) {
            return null;
        }
        owned.setMode(draft.getMode());
        owned.setToUserId(draft.getToUserId());
        owned.setContentJson(draft.getContentJson());
        owned.updateAudit(auditUserId);
        updateById(owned);
        return owned;
    }

    @Override
    public void softDeleteOwned(Long userId, Long draftId) {
        if (userId == null || draftId == null) {
            return;
        }
        LetterDraftDomain owned = findOwned(userId, draftId);
        if (owned == null) {
            return;
        }
        owned.setDelFlag(true);
        owned.setUpdatedAt(LocalDateTime.now());
        owned.setUpdatedBy(userId);
        updateById(owned);
    }
}
