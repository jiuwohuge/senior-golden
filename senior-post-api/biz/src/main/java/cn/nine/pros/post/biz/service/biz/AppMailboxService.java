package cn.nine.pros.post.biz.service.biz;

import cn.nine.pros.post.client.model.input.app.AppSendLetterInDto;
import cn.nine.pros.post.client.model.out.AcceptPostalContactResultVO;
import cn.nine.pros.post.client.model.out.LetterSyncResultVO;
import cn.nine.pros.post.client.model.out.MailboxFriendItemVO;
import cn.nine.pros.post.client.model.out.MailboxLetterItemVO;

import java.time.LocalDateTime;
import java.util.List;

public interface AppMailboxService {

    List<MailboxLetterItemVO> listPostalInbox(Long userId);

    LetterSyncResultVO sync(Long userId, LocalDateTime since);

    List<MailboxLetterItemVO> listArchive(Long userId);

    AcceptPostalContactResultVO acceptPostalContact(Long actorUserId, Long letterId);

    /**
     * 当前用户向 {@code body.toUserId} 发送信件。
     */
    MailboxLetterItemVO sendLetter(long fromUserId, AppSendLetterInDto body);

    MailboxLetterItemVO getLetter(long viewerUserId, long letterId);

    List<MailboxFriendItemVO> listFriends(Long userId);

    boolean isFriendshipActive(long viewerUserId, long peerUserId);

    /**
     * 发件人对运输中的平邮加速：非 VIP 扣 1 邮票，VIP 免扣；信件变为已送达。
     */
    MailboxLetterItemVO speedUpLetter(long actorUserId, long letterId);

    /**
     * 收件人对运输中的平邮提前拆信：非 VIP 扣 1 邮票，VIP 免扣；不改变送达状态，仅解锁正文。
     */
    MailboxLetterItemVO earlyOpenLetter(long actorUserId, long letterId);
}
