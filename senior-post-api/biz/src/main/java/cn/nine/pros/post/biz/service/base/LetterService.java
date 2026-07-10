package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.LetterDomain;
import com.baomidou.mybatisplus.extension.service.IService;
import cn.nine.pros.post.client.model.db.LetterDTO;

import java.time.LocalDateTime;
import java.util.List;


/**
 * 信件表（挂号信/平邮） Service
 *
 * @author Administrator
 */
public interface LetterService extends IService<LetterDomain> {

    void upsert(LetterDTO letterDTO);

    LetterDTO findById(Long id);

    void delByIds(List<Long> ids);

    long countPeerLetterReferencingContent(long viewerUserId, long ownerUserId, List<String> variants);

    /** 发件人在时间窗内发出的信件数（含 POST_OFFICE 入池）。 */
    long countSentByFromUserBetween(long fromUserId, LocalDateTime start, LocalDateTime end);

    /** 发件人指定状态信件数。 */
    long countByFromUserAndStatus(long fromUserId, int status);

    /** 收件人指定状态信件数。 */
    long countByToUserAndStatus(long toUserId, int status);

    /** 收件人已送达且未读（recipient_read_at 为空）。 */
    long countUnreadDeliveredForToUser(long toUserId);

    /** 未删除信件总数（管理看板）。 */
    long countActive();

    /**
     * 用户作为发件人或收件人的信件；可选 since（COALESCE(updated_at,created_at) &gt; since）。
     */
    List<LetterDomain> listMailboxForUser(long userId, LocalDateTime since, int limit);

    /** 用户最近发出的信件正文样本（写作风格）。 */
    List<LetterDomain> listRecentByFromUser(long fromUserId, int limit);

    /**
     * 收件人首次打开已送达信件时标记已读；成功返回 true。
     */
    boolean markRecipientRead(long letterId, long toUserId, LocalDateTime at);

    /**
     * 提前拆信：运输中 → 已送达并标记 early_open / read；成功返回 true。
     */
    boolean markEarlyOpenedAndDelivered(long letterId, long toUserId, LocalDateTime at);

    /** 到期待送达的在途信。 */
    List<LetterDomain> listDueDelivering(LocalDateTime now, int limit);

    /** 审核拒绝后中止投递（DELIVERING → PENDING）。 */
    boolean abortDeliveryRejected(long letterId, LocalDateTime at);

    /** 标记已送达。 */
    boolean markDelivered(long letterId, LocalDateTime at);

}
