package cn.nine.pros.post.biz.service.base;

import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.model.domain.TimeLetterDomain;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;

import java.time.LocalDateTime;
import java.util.List;

public interface TimeLetterService extends IService<TimeLetterDomain> {

    TimeLetterDomain findBySenderAndSealRequestId(long senderId, String sealRequestId);

    boolean cancelPending(long letterId, long senderId, LocalDateTime at);

    boolean markRead(long letterId, long actorUserId, LocalDateTime at);

    boolean updateStarFlag(long letterId, long actorUserId, boolean starFlag);

    boolean adminTakedown(long letterId, String reason, LocalDateTime at);

    Page<TimeLetterDomain> pageOutbox(long userId, boolean starredOnly, PageQuery pageQuery);

    Page<TimeLetterDomain> pageInbox(long userId, PageQuery pageQuery);

    Page<TimeLetterDomain> pageMemorial(long userId, boolean starredOnly, PageQuery pageQuery);

    long countInFlightBySender(long senderId);

    long countUnreadDeliveredForUser(long userId);

    long countMemorialForUser(long userId);

    long countTodayDeliveredForUser(long userId, LocalDateTime dayStart, LocalDateTime dayEnd);

    List<TimeLetterDomain> listRecentSealedWithRecipient(long senderId, int limit);

    long countSealedTodayBySender(long senderId, LocalDateTime dayStart);

    long countSealedToRecipientSince(long senderId, long recipientId, LocalDateTime since);

    List<TimeLetterDomain> listPendingForDelivery(int limit);

    boolean markDelivered(long letterId, LocalDateTime at);

    boolean markFailed(long letterId, String reason, LocalDateTime at);

    com.baomidou.mybatisplus.extension.plugins.pagination.Page<TimeLetterDomain> pageForAdmin(
            cn.nine.commons.data.page.PageQuery pageQuery, Long senderId, Long recipientId, Integer status);

}
