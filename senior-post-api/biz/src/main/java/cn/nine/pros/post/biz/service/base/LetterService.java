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

    /** POST_OFFICE 入池待匹配：mode=POST_OFFICE、status=PENDING、无收件人。 */
    List<LetterDomain> listPostOfficePendingPool(int limit);

    /**
     * 原子匹配：仍为 PENDING 且无收件人时写入收件人与 MATCHED。
     * @return 是否更新成功
     */
    boolean tryAssignMatch(long letterId, long toUserId, LocalDateTime matchedAt);

    /** MATCHED → DELIVERING，并写入预计送达时间。 */
    boolean startDeliveringAfterMatch(long letterId, LocalDateTime eta, LocalDateTime now);

    /** 用户当日作为 POST_OFFICE 收件人已匹配/在途/已达数量（用于 inbound cap）。 */
    long countInboundPostOfficeSince(long toUserId, LocalDateTime since);

    /** 额度计数：发件人时间窗内发出且未审核拒绝的信件数。 */
    long countSentQuotaByFromUserBetween(long fromUserId, LocalDateTime start, LocalDateTime end);

    /** 审核通过。 */
    boolean approveAudit(long letterId, LocalDateTime at, Long auditUserId);

    /** 审核拒绝。 */
    boolean rejectAudit(long letterId, LocalDateTime at, Long auditUserId);

    /** 超时未审的 PENDING_REVIEW 列表（用于自动放行）。 */
    List<LetterDomain> listPendingReviewBefore(LocalDateTime createdBefore, int limit);

    /** 管理端按审核状态分页。 */
    com.baomidou.mybatisplus.extension.plugins.pagination.Page<LetterDomain> pageForAdminAudit(
            cn.nine.commons.data.page.PageQuery pageQuery, Integer auditStatus, Integer mode);

    /** 用户发出的信件总数（保护池）。 */
    long countLettersSentByUser(long userId);

    /** 两用户间有效往来信件数（已送达及以上，非审核拒绝）。 */
    long countExchangeBetween(long userIdA, long userIdB);

    /** 是否至少各有一封有效送达信件（双向往来）。 */
    boolean hasBidirectionalExchange(long userIdA, long userIdB);

    /** 用户参与的有效信件总数（发或收，已送达）。 */
    long countDeliveredParticipationForUser(long userId);

    /** 收件人流水：本人为收件人且已有收件人。 */
    List<LetterDomain> listReceivedForUser(long userId, int limit);

    /** 发件人流水：本人为发件人。 */
    List<LetterDomain> listSentForUser(long userId, int limit);

    /** 与 viewer 有过有效往来的对端用户 ID（去重，按最近更新时间）。 */
    List<Long> listExchangePeerIds(long viewerUserId, int limit);

    /** 已送达信件导出：用户参与且可选笔友/日期范围。 */
    List<LetterDomain> listDeliveredForExport(
            long userId, Long peerUserId, LocalDateTime from, LocalDateTime to, int limit);

}
