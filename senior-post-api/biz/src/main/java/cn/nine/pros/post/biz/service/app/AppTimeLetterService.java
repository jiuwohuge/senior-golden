package cn.nine.pros.post.biz.service.app;

import cn.nine.commons.data.page.PageData;
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

import java.util.List;

public interface AppTimeLetterService {

    TimeLetterDetailVO saveDraft(long userId, TimeLetterDraftSaveInDto body);

    TimeLetterDetailVO getDraft(long userId, long draftId);

    void deleteDraft(long userId, long draftId);

    TimeLetterSealResultVO seal(long userId, TimeLetterSealInDto body);

    void cancel(long userId, long letterId);

    PageData<TimeLetterListItemVO> outboxPage(long userId, TimeLetterPageInDto body);

    PageData<TimeLetterListItemVO> inboxPage(long userId, TimeLetterPageInDto body);

    PageData<TimeLetterListItemVO> memorialPage(long userId, TimeLetterPageInDto body);

    TimeLetterDetailVO getDetail(long userId, long letterId);

    TimeLetterDetailVO open(long userId, long letterId);

    void toggleStar(long userId, long letterId);

    TimeLetterStatsVO stats(long userId);

    TimeLetterPreviewDeliveryVO previewDelivery(long userId, TimeLetterPreviewDeliveryInDto body);

    List<TimeLetterRecentRecipientVO> recentRecipients(long userId);
}
