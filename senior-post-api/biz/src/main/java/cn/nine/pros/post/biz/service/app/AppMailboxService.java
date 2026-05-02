package cn.nine.pros.post.biz.service.app;

import cn.nine.pros.post.client.model.out.AcceptPostalContactResultVO;
import cn.nine.pros.post.client.model.out.LetterSyncResultVO;
import cn.nine.pros.post.client.model.out.MailboxLetterItemVO;

import java.time.LocalDateTime;
import java.util.List;

public interface AppMailboxService {

    List<MailboxLetterItemVO> listPostalInbox(Long userId);

    LetterSyncResultVO sync(Long userId, LocalDateTime since);

    List<MailboxLetterItemVO> listArchive(Long userId);

    AcceptPostalContactResultVO acceptPostalContact(Long actorUserId, Long letterId);
}
