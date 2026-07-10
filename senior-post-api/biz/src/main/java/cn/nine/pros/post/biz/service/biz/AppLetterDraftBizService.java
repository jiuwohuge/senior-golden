package cn.nine.pros.post.biz.service.biz;

import cn.nine.pros.post.client.model.input.app.LetterDraftSaveInDto;
import cn.nine.pros.post.client.model.out.LetterDraftVO;
import cn.nine.pros.post.client.model.out.MailboxLetterItemVO;

import java.util.List;

public interface AppLetterDraftBizService {

    List<LetterDraftVO> listDrafts(long userId);

    LetterDraftVO saveDraft(long userId, LetterDraftSaveInDto body);

    void deleteDraft(long userId, long draftId);

    MailboxLetterItemVO sendDraft(long userId, long draftId);
}
