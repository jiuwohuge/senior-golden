package cn.nine.pros.post.biz.controller.app;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.service.biz.AppLetterDraftBizService;
import cn.nine.pros.post.client.api.app.AppLetterDraftApi;
import cn.nine.pros.post.client.model.input.app.LetterDraftSaveInDto;
import cn.nine.pros.post.client.model.out.LetterDraftVO;
import cn.nine.pros.post.client.model.out.MailboxLetterItemVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class AppLetterDraftController implements AppLetterDraftApi {

    private final AppLetterDraftBizService appLetterDraftBizService;
    private final AppMessages appMessages;

    @Override
    public List<LetterDraftVO> listDrafts() {
        return appLetterDraftBizService.listDrafts(requireUserId());
    }

    @Override
    public LetterDraftVO saveDraft(LetterDraftSaveInDto body) {
        return appLetterDraftBizService.saveDraft(requireUserId(), body);
    }

    @Override
    public void deleteDraft(Long id) {
        appLetterDraftBizService.deleteDraft(requireUserId(), id);
    }

    @Override
    public MailboxLetterItemVO sendDraft(Long id) {
        return appLetterDraftBizService.sendDraft(requireUserId(), id);
    }

    private Long requireUserId() {
        Long uid = MyRequestContextHolder.userId();
        if (uid == null) {
            throw new BadRequestException(appMessages.get("app.error.notLoggedIn"));
        }
        return uid;
    }
}
