package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.LetterDraftDomain;
import com.baomidou.mybatisplus.extension.service.IService;

import java.util.List;

public interface LetterDraftService extends IService<LetterDraftDomain> {

    List<LetterDraftDomain> listForUser(Long userId);

    LetterDraftDomain findOwned(Long userId, Long draftId);

    LetterDraftDomain saveOwned(LetterDraftDomain draft, Long actorId);

    void softDeleteOwned(Long userId, Long draftId);
}
