package cn.nine.pros.post.biz.service.biz;

import cn.nine.pros.post.client.model.input.app.AppLetterAssistantInDto;
import cn.nine.pros.post.client.model.input.app.AppSendLetterInDto;
import cn.nine.pros.post.client.model.input.app.InTransitLetterEditInDto;
import cn.nine.pros.post.client.model.out.AcceptPostalContactResultVO;
import cn.nine.pros.post.client.model.out.AppLetterAssistantVO;
import cn.nine.pros.post.client.model.out.InTransitWithdrawResultVO;
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
     * <p>带周配额闸：未订约用免费额，试用/订阅用高配额；成功后计次。
     */
    AppLetterAssistantVO letterAssistant(long userId, AppLetterAssistantInDto body);

    /**
     * 在途改信：本人 outbound + 窗口内 + Plus entitled。
     */
    MailboxLetterItemVO inTransitEdit(long userId, long letterId, InTransitLetterEditInDto body);

    /**
     * 在途撤回：复制正文到草稿并软删信件。
     */
    InTransitWithdrawResultVO inTransitWithdraw(long userId, long letterId);
}
