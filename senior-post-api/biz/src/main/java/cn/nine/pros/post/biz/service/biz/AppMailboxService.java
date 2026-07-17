package cn.nine.pros.post.biz.service.biz;

import cn.nine.pros.post.client.model.input.app.AppLetterAssistantInDto;
import cn.nine.pros.post.client.model.input.app.AppSendLetterInDto;
import cn.nine.pros.post.client.model.out.AcceptPostalContactResultVO;
import cn.nine.pros.post.client.model.out.AppLetterAssistantVO;
import cn.nine.pros.post.client.model.out.LetterSyncResultVO;
import cn.nine.pros.post.client.model.out.MailboxFriendItemVO;
import cn.nine.pros.post.client.model.out.MailboxLetterItemVO;

import java.time.LocalDateTime;
import java.util.List;

public interface AppMailboxService {

    List<MailboxLetterItemVO> listPostalInbox(Long userId);

    LetterSyncResultVO sync(Long userId, LocalDateTime since);

    List<MailboxLetterItemVO> listArchive(Long userId);

    List<MailboxLetterItemVO> listReceived(Long userId);

    List<MailboxLetterItemVO> listSent(Long userId);

    AcceptPostalContactResultVO acceptPostalContact(Long actorUserId, Long letterId);

    /**
     * 当前用户向 {@code body.toUserId} 发送信件。
     */
    MailboxLetterItemVO sendLetter(long fromUserId, AppSendLetterInDto body);

    MailboxLetterItemVO getLetter(long viewerUserId, long letterId);

    List<MailboxFriendItemVO> listFriends(Long userId);

    /**
     * 信件助手：整理用户原文为建议稿（Spring AI；不落库、不覆盖）。
     */
    AppLetterAssistantVO letterAssistant(long userId, AppLetterAssistantInDto body);
}
