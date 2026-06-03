package cn.nine.pros.post.biz.controller.app;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.service.app.AppTimeLetterService;
import cn.nine.pros.post.client.api.app.AppTimeLetterApi;
import cn.nine.pros.post.client.model.input.app.TimeLetterDraftSaveInDto;
import cn.nine.pros.post.client.model.input.app.TimeLetterPageInDto;
import cn.nine.pros.post.client.model.input.app.TimeLetterPreviewDeliveryInDto;
import cn.nine.pros.post.client.model.input.app.TimeLetterSealInDto;
import cn.nine.pros.post.client.model.out.TimeLetterDetailVO;
import cn.nine.pros.post.client.model.out.TimeLetterListItemVO;
import cn.nine.pros.post.client.model.out.TimeLetterPreviewDeliveryVO;
import cn.nine.pros.post.client.model.out.TimeLetterRecentRecipientVO;
import cn.nine.pros.post.client.model.out.TimeLetterSealResultVO;
import cn.nine.pros.post.client.model.out.TimeLetterStatsVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class AppTimeLetterController implements AppTimeLetterApi {

    private final AppTimeLetterService appTimeLetterService;
    private final AppMessages appMessages;

    @Override
    public TimeLetterDetailVO saveDraft(TimeLetterDraftSaveInDto body) {
        return appTimeLetterService.saveDraft(requireUserId(), body);
    }

    @Override
    public TimeLetterDetailVO getDraft(Long id) {
        return appTimeLetterService.getDraft(requireUserId(), id);
    }

    @Override
    public void deleteDraft(Long id) {
        appTimeLetterService.deleteDraft(requireUserId(), id);
    }

    @Override
    public TimeLetterSealResultVO seal(TimeLetterSealInDto body) {
        return appTimeLetterService.seal(requireUserId(), body);
    }

    @Override
    public void cancel(Long id) {
        appTimeLetterService.cancel(requireUserId(), id);
    }

    @Override
    public PageData<TimeLetterListItemVO> outboxPaging(TimeLetterPageInDto body) {
        return appTimeLetterService.outboxPage(requireUserId(), body);
    }

    @Override
    public PageData<TimeLetterListItemVO> inboxPaging(TimeLetterPageInDto body) {
        return appTimeLetterService.inboxPage(requireUserId(), body);
    }

    @Override
    public PageData<TimeLetterListItemVO> memorialPaging(TimeLetterPageInDto body) {
        return appTimeLetterService.memorialPage(requireUserId(), body);
    }

    @Override
    public TimeLetterDetailVO getDetail(Long id) {
        return appTimeLetterService.getDetail(requireUserId(), id);
    }

    @Override
    public TimeLetterDetailVO open(Long id) {
        return appTimeLetterService.open(requireUserId(), id);
    }

    @Override
    public void toggleStar(Long id) {
        appTimeLetterService.toggleStar(requireUserId(), id);
    }

    @Override
    public TimeLetterStatsVO stats() {
        return appTimeLetterService.stats(requireUserId());
    }

    @Override
    public TimeLetterPreviewDeliveryVO previewDelivery(TimeLetterPreviewDeliveryInDto body) {
        return appTimeLetterService.previewDelivery(requireUserId(), body);
    }

    @Override
    public List<TimeLetterRecentRecipientVO> recentRecipients() {
        return appTimeLetterService.recentRecipients(requireUserId());
    }

    private long requireUserId() {
        Long uid = MyRequestContextHolder.userId();
        if (uid == null) {
            throw new BadRequestException(appMessages.get("app.error.notLoggedIn"));
        }
        return uid;
    }
}
