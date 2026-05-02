package cn.nine.pros.post.biz.controller.app;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.service.app.AppMailboxService;
import cn.nine.pros.post.client.api.app.AppMailboxApi;
import cn.nine.pros.post.client.model.out.AcceptPostalContactResultVO;
import cn.nine.pros.post.client.model.out.LetterSyncResultVO;
import cn.nine.pros.post.client.model.out.MailboxLetterItemVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequiredArgsConstructor
public class AppMailboxController implements AppMailboxApi {

    private final AppMailboxService appMailboxService;

    @Override
    public List<MailboxLetterItemVO> listPostalInbox() {
        Long uid = requireUserId();
        return appMailboxService.listPostalInbox(uid);
    }

    @Override
    public LetterSyncResultVO sync(LocalDateTime since) {
        Long uid = requireUserId();
        return appMailboxService.sync(uid, since);
    }

    @Override
    public List<MailboxLetterItemVO> listArchive() {
        Long uid = requireUserId();
        return appMailboxService.listArchive(uid);
    }

    @Override
    public AcceptPostalContactResultVO acceptPostalContact(Long letterId) {
        Long uid = requireUserId();
        return appMailboxService.acceptPostalContact(uid, letterId);
    }

    private static Long requireUserId() {
        Long uid = MyRequestContextHolder.userId();
        if (uid == null) {
            throw new BadRequestException("未登录");
        }
        return uid;
    }
}
