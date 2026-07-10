package cn.nine.pros.post.biz.service.biz.impl;

import cn.nine.commons.basic.exception.unchecked.BusinessException;
import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.config.TimeLetterProperties;
import cn.nine.pros.post.biz.controller.app.AppPageHelper;
import cn.nine.pros.post.biz.error.PostAppErrorCodes;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.model.domain.TimeLetterDomain;
import cn.nine.pros.post.biz.service.biz.AppBlacklistService;
import cn.nine.pros.post.biz.service.biz.AppTimeLetterService;
import cn.nine.pros.post.biz.service.biz.support.UserAvatarAuditSupport;
import cn.nine.pros.post.biz.service.base.FriendshipService;
import cn.nine.pros.post.biz.service.base.OssDisplayUrlService;
import cn.nine.pros.post.biz.service.base.SensitiveWordService;
import cn.nine.pros.post.biz.service.base.TimeLetterService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.client.common.enums.TimeLetterRecipientType;
import cn.nine.pros.post.client.common.enums.TimeLetterStatus;
import cn.nine.pros.post.client.model.db.UserDTO;
import cn.nine.pros.post.client.model.input.app.TimeLetterDraftSaveInDto;
import cn.nine.pros.post.client.model.input.app.TimeLetterPageInDto;
import cn.nine.pros.post.client.model.input.app.TimeLetterPreviewDeliveryInDto;
import cn.nine.pros.post.client.model.input.app.TimeLetterSealInDto;
import cn.nine.pros.post.client.model.out.AppPublicUserVO;
import cn.nine.pros.post.client.model.out.TimeLetterDetailVO;
import cn.nine.pros.post.client.model.out.TimeLetterListItemVO;
import cn.nine.pros.post.client.model.out.TimeLetterPreviewDeliveryVO;
import cn.nine.pros.post.client.model.out.TimeLetterRecentRecipientVO;
import cn.nine.pros.post.client.model.out.TimeLetterSealResultVO;
import cn.nine.pros.post.client.model.out.TimeLetterStatsVO;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * App 时光信业务：草稿、封存、取消、收发件箱、纪念册与统计。
 * <p>封存成功打 INFO；日限额/在途/同收件人 30 天限额拒绝打 INFO。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AppTimeLetterServiceImpl implements AppTimeLetterService {

    private static final int USER_STATUS_NORMAL = 1;

        private final TimeLetterService timeLetterService;
    private final UserService userService;
    private final SensitiveWordService sensitiveWordService;
    private final FriendshipService friendshipService;
    private final AppBlacklistService appBlacklistService;
    private final OssDisplayUrlService ossDisplayUrlService;
    private final TimeLetterProperties properties;
    private final AppMessages appMessages;

    /**
     * 保存时光信草稿（新建或更新已有草稿）。
     * <p>前置：发件人状态正常、投递日合法；副作用：写/更新 DRAFT 记录。
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public TimeLetterDetailVO saveDraft(long userId, TimeLetterDraftSaveInDto body) {
        assertSenderActive(userId);
        ResolvedRecipient resolved = resolveRecipient(userId, body.getRecipientId(), false);
        String content = normalizeBody(body.getBody(), false);
        validateDeliveryDate(body.getDeliveryDate(), body.getDeliveryTz());

        TimeLetterDomain d;
        if (body.getId() != null) {
            d = loadOwnedDraft(userId, body.getId());
            applyDraftFields(d, resolved, content, body);
            d.updateAudit(userId);
            timeLetterService.updateById(d);
        } else {
            d = new TimeLetterDomain();
            d.setSenderId(userId);
            d.setStatus(TimeLetterStatus.DRAFT.getCode());
            d.setStampCost(0);
            d.setStarFlag(false);
            d.setPrivacyLevel(1);
            applyDraftFields(d, resolved, content, body);
            d.initAudit(userId);
            timeLetterService.save(d);
        }
        return toDetail(d, userId, true);
    }

    /**
     * 读取本人草稿详情。
     * <p>前置：草稿归属当前用户且状态为 DRAFT。
     */
    @Override
    public TimeLetterDetailVO getDraft(long userId, long draftId) {
        return toDetail(loadOwnedDraft(userId, draftId), userId, true);
    }

    /**
     * 软删除本人草稿。
     * <p>前置：草稿归属当前用户；副作用：markDeleted。
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteDraft(long userId, long draftId) {
        TimeLetterDomain d = loadOwnedDraft(userId, draftId);
        d.markDeleted(userId);
        timeLetterService.updateById(d);
        log.info("time-letter draft deleted, userId={}, draftId={}", userId, draftId);
    }

    /**
     * 封存时光信：幂等 sealRequestId；过敏感词与额度后进入 PENDING。
     * <p>前置：发件人正常、好友/自投递合法、投递日合法、未超日/在途/30 天限额。
     * <p>副作用：写 PENDING 记录与 cancelDeadline；事务边界为本方法。
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public TimeLetterSealResultVO seal(long userId, TimeLetterSealInDto body) {
        assertSenderActive(userId);
        if (!StringUtils.hasText(body.getSealRequestId())) {
            throw new BusinessException(appMessages.get("app.timeLetter.error.sealRequestRequired"));
        }
        TimeLetterDomain existing = timeLetterService.findBySenderAndSealRequestId(
                userId, body.getSealRequestId().trim());
        if (existing != null && existing.getStatus() != null
                && existing.getStatus() != TimeLetterStatus.DRAFT.getCode()) {
            log.debug("time-letter seal idempotent hit, userId={}, letterId={}", userId, existing.getId());
            int bal = 0;
            return TimeLetterSealResultVO.builder()
                    .id(existing.getId())
                    .status(existing.getStatus())
                    .deliveryDate(existing.getDeliveryDate())
                    .cancelDeadlineAt(existing.getCancelDeadlineAt())
                    .stampCost(existing.getStampCost())
                    .stampBalanceAfter(bal)
                    .build();
        }

        ResolvedRecipient resolved = resolveRecipient(userId, body.getRecipientId(), true);
        String content = normalizeBody(body.getBody(), true);
        sensitiveWordService.assertPlainTextAllowed(content);
        validateDeliveryDate(body.getDeliveryDate(), body.getDeliveryTz());
        assertSealLimits(userId, resolved.recipientId, body.getDeliveryDate());

        int stampCost = 0;
        LocalDateTime now = LocalDateTime.now();
        TimeLetterDomain d;
        if (body.getDraftId() != null) {
            d = loadOwnedDraft(userId, body.getDraftId());
        } else if (existing != null) {
            d = existing;
        } else {
            d = new TimeLetterDomain();
            d.setSenderId(userId);
            d.initAudit(userId);
        }
        applySealFields(d, resolved, content, body, now, stampCost);
        try {
            if (d.getId() == null) {
                timeLetterService.save(d);
            } else {
                d.updateAudit(userId);
                timeLetterService.updateById(d);
            }
        } catch (DuplicateKeyException e) {
            log.info("time-letter seal rejected: same-day duplicate, userId={}", userId);
            throw new BusinessException(appMessages.get("app.timeLetter.error.sameDayDuplicate"));
        }

        log.info("time-letter sealed, userId={}, letterId={}, deliveryDate={}",
                userId, d.getId(), d.getDeliveryDate());
        return TimeLetterSealResultVO.builder()
                .id(d.getId())
                .status(d.getStatus())
                .deliveryDate(d.getDeliveryDate())
                .cancelDeadlineAt(d.getCancelDeadlineAt())
                .stampCost(stampCost)
                .stampBalanceAfter(0)
                .build();
    }

    /**
     * 取消待投递时光信（须在 cancelDeadline 内）。
     * <p>前置：本人 PENDING 且未过取消窗；副作用：状态改为 CANCELLED。
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void cancel(long userId, long letterId) {
        TimeLetterDomain d = loadOwnedPending(userId, letterId);
        LocalDateTime now = LocalDateTime.now();
        if (d.getCancelDeadlineAt() == null || now.isAfter(d.getCancelDeadlineAt())) {
            log.info("time-letter cancel rejected: window expired, userId={}, letterId={}", userId, letterId);
            throw new BusinessException(appMessages.get("app.timeLetter.error.cancelWindowExpired"));
        }
        if (!timeLetterService.cancelPending(letterId, userId, now)) {
            log.info("time-letter cancel rejected: state changed, userId={}, letterId={}", userId, letterId);
            throw new BusinessException(appMessages.get("app.timeLetter.error.stateChanged"));
        }
        log.info("time-letter cancelled, userId={}, letterId={}", userId, letterId);
    }

    /**
     * 发件箱分页（可筛星标）。
     */
    @Override
    public PageData<TimeLetterListItemVO> outboxPage(long userId, TimeLetterPageInDto body) {
        PageQuery pq = AppPageHelper.normalize(body == null ? null : body.getPage());
        boolean starredOnly = body != null && Boolean.TRUE.equals(body.getStarredOnly());
        return pageList(userId, pq, timeLetterService.pageOutbox(userId, starredOnly, pq), true);
    }

    /**
     * 收件箱分页（已送达/已读等对收件人可见状态）。
     */
    @Override
    public PageData<TimeLetterListItemVO> inboxPage(long userId, TimeLetterPageInDto body) {
        PageQuery pq = AppPageHelper.normalize(body == null ? null : body.getPage());
        return pageList(userId, pq, timeLetterService.pageInbox(userId, pq), false);
    }

    /**
     * 纪念册分页（已读且可星标的时光信）。
     */
    @Override
    public PageData<TimeLetterListItemVO> memorialPage(long userId, TimeLetterPageInDto body) {
        PageQuery pq = AppPageHelper.normalize(body == null ? null : body.getPage());
        boolean starredOnly = body != null && Boolean.TRUE.equals(body.getStarredOnly());
        return pageList(userId, pq, timeLetterService.pageMemorial(userId, starredOnly, pq), null);
    }

    /**
     * 详情：发/收件人可访问；正文按状态与角色决定是否返回。
     */
    @Override
    public TimeLetterDetailVO getDetail(long userId, long letterId) {
        TimeLetterDomain d = loadAccessible(userId, letterId);
        boolean showBody = canViewBody(d, userId);
        return toDetail(d, userId, showBody);
    }

    /**
     * 收件人拆开已送达时光信并标记已读。
     * <p>前置：当前用户为收件人且状态 DELIVERED；副作用：写 readAt/READ。
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public TimeLetterDetailVO open(long userId, long letterId) {
        TimeLetterDomain d = loadAccessible(userId, letterId);
        if (!isRecipient(userId, d)) {
            throw new BusinessException(appMessages.get("app.timeLetter.error.openRecipientOnly"));
        }
        if (d.getStatus() == null || d.getStatus() != TimeLetterStatus.DELIVERED.getCode()) {
            throw new BusinessException(appMessages.get("app.timeLetter.error.notDelivered"));
        }
        LocalDateTime now = LocalDateTime.now();
        if (!timeLetterService.markRead(letterId, userId, now)) {
            throw new BusinessException(appMessages.get("app.timeLetter.error.stateChanged"));
        }
        log.info("time-letter opened, userId={}, letterId={}", userId, letterId);
        d = timeLetterService.getById(letterId);
        return toDetail(d, userId, true);
    }

    /**
     * 切换已读时光信星标（纪念册）。
     * <p>前置：状态为 READ；副作用：翻转 starFlag。
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void toggleStar(long userId, long letterId) {
        TimeLetterDomain d = loadAccessible(userId, letterId);
        if (d.getStatus() == null || d.getStatus() != TimeLetterStatus.READ.getCode()) {
            throw new BusinessException(appMessages.get("app.timeLetter.error.starReadOnly"));
        }
        boolean next = !Boolean.TRUE.equals(d.getStarFlag());
        timeLetterService.updateStarFlag(letterId, userId, next);
    }

    /**
     * 时光信角标统计：在途/未读/纪念册/今日送达。
     */
    @Override
    public TimeLetterStatsVO stats(long userId) {
        long inFlight = timeLetterService.countInFlightBySender(userId);
        long unread = timeLetterService.countUnreadDeliveredForUser(userId);
        long memorial = timeLetterService.countMemorialForUser(userId);
        LocalDate today = LocalDate.now();
        LocalDateTime todayStart = today.atStartOfDay();
        LocalDateTime tomorrowStart = today.plusDays(1).atStartOfDay();
        long todayDelivered = timeLetterService.countTodayDeliveredForUser(userId, todayStart, tomorrowStart);
        return TimeLetterStatsVO.builder()
                .inFlightCount((int) inFlight)
                .deliveredUnreadCount((int) unread)
                .memorialCount((int) memorial)
                .todayDeliveredCount((int) todayDelivered)
                .build();
    }

    /**
     * 预览投递日是否合法及距投递天数（不写库）。
     */
    @Override
    public TimeLetterPreviewDeliveryVO previewDelivery(long userId, TimeLetterPreviewDeliveryInDto body) {
        if (body == null || body.getDeliveryDate() == null) {
            return TimeLetterPreviewDeliveryVO.builder().valid(false)
                    .message(appMessages.get("app.timeLetter.error.deliveryDateRequired"))
                    .build();
        }
        try {
            validateDeliveryDate(body.getDeliveryDate(), body.getDeliveryTz());
            ZoneId zone = resolveZone(body.getDeliveryTz());
            LocalDate today = ZonedDateTime.now(zone).toLocalDate();
            int days = (int) ChronoUnit.DAYS.between(today, body.getDeliveryDate());
            return TimeLetterPreviewDeliveryVO.builder()
                    .deliveryDate(body.getDeliveryDate())
                    .deliveryTz(zone.getId())
                    .daysUntilDelivery(Math.max(0, days))
                    .valid(true)
                    .build();
        } catch (BusinessException e) {
            return TimeLetterPreviewDeliveryVO.builder()
                    .deliveryDate(body.getDeliveryDate())
                    .valid(false)
                    .message(e.getMessage())
                    .build();
        }
    }

    /**
     * 最近封存过的收件人（最多 3 个，状态正常）。
     */
    @Override
    public List<TimeLetterRecentRecipientVO> recentRecipients(long userId) {
        List<TimeLetterDomain> rows = timeLetterService.listRecentSealedWithRecipient(userId, 30);
        Set<Long> seen = new LinkedHashSet<>();
        List<TimeLetterRecentRecipientVO> out = new ArrayList<>();
        for (TimeLetterDomain r : rows) {
            if (r.getRecipientId() == null || !seen.add(r.getRecipientId())) {
                continue;
            }
            if (out.size() >= 3) {
                break;
            }
            UserDTO u = userService.findById(r.getRecipientId());
            if (u == null || userStatus(u.getStatus()) != USER_STATUS_NORMAL) {
                continue;
            }
            out.add(TimeLetterRecentRecipientVO.builder()
                    .userId(u.getId())
                    .nickname(u.getNickname())
                    .avatarUrl(signAvatar(userId, u))
                    .countryLabel(u.getCountryCode())
                    .build());
        }
        return out;
    }

    private PageData<TimeLetterListItemVO> pageList(
            long userId, PageQuery pq, Page<TimeLetterDomain> p, Boolean outbox) {
        List<TimeLetterListItemVO> list = p.getRecords().stream()
                .map(d -> toListItem(d, userId, outbox))
                .collect(Collectors.toList());
        return AppPageHelper.pageData(pq, p, list);
    }

    private void assertSealLimits(long userId, Long recipientId, LocalDate deliveryDate) {
        LocalDateTime dayStart = LocalDate.now().atStartOfDay();
        long todayCount = timeLetterService.countSealedTodayBySender(userId, dayStart);
        if (todayCount >= properties.getDailyCreateLimit()) {
            log.info("time-letter seal rejected: daily limit, userId={}, todayCount={}", userId, todayCount);
            throw new BusinessException(appMessages.get("app.timeLetter.error.dailyLimit"));
        }
        long inFlight = timeLetterService.countInFlightBySender(userId);
        if (inFlight >= properties.getInFlightLimit()) {
            log.info("time-letter seal rejected: in-flight limit, userId={}, inFlight={}", userId, inFlight);
            throw new BusinessException(appMessages.get("app.timeLetter.error.inFlightLimit"));
        }
        assertRecipient30dLimit(userId, recipientId);
    }

    /**
     * 校验对同一收件人近 30 天封存次数上限；无收件人时跳过。
     */
    private void assertRecipient30dLimit(long userId, Long recipientId) {
        if (recipientId == null) {
            return;
        }
        LocalDateTime since30 = LocalDateTime.now().minusDays(30);
        long toRecipient = timeLetterService.countSealedToRecipientSince(userId, recipientId, since30);
        if (toRecipient >= properties.getRecipient30dLimit()) {
            log.info("time-letter seal rejected: recipient 30d limit, userId={}, recipientId={}, count={}",
                    userId, recipientId, toRecipient);
            throw new BusinessException(appMessages.get("app.timeLetter.error.recipient30dLimit"));
        }
    }

    private ResolvedRecipient resolveRecipient(long userId, Long recipientId, boolean strictFriend) {
        if (recipientId == null || recipientId.equals(userId)) {
            return new ResolvedRecipient(null, TimeLetterRecipientType.SELF.getCode());
        }
        if (recipientId.equals(userId)) {
            throw new BusinessException(appMessages.get("app.timeLetter.error.cannotSendSelfAsFriend"));
        }
        UserDTO to = userService.findById(recipientId);
        if (to == null) {
            throw new BusinessException(appMessages.get("app.error.recipient.notFound"));
        }
        if (userStatus(to.getStatus()) != USER_STATUS_NORMAL) {
            throw new BusinessException(appMessages.get("app.error.recipient.statusBad"));
        }
        if (appBlacklistService.areMutuallyBlocked(userId, recipientId)) {
            throw new BusinessException(appMessages.get("app.error.mail.cannotSendToPeer"));
        }
        if (strictFriend && !friendshipService.areActiveFriends(userId, recipientId)) {
            throw new BusinessException(appMessages.get("app.timeLetter.error.notMutualFriend"));
        }
        return new ResolvedRecipient(recipientId, TimeLetterRecipientType.FRIEND.getCode());
    }

    private void assertSenderActive(long userId) {
        UserDTO sender = userService.findById(userId);
        if (sender == null || userStatus(sender.getStatus()) != USER_STATUS_NORMAL) {
            throw new BusinessException(appMessages.get("app.error.sender.statusBad"));
        }
    }

    private String normalizeBody(String raw, boolean required) {
        if (!StringUtils.hasText(raw)) {
            assertBodyPresentIfRequired(required);
            return "";
        }
        String content = raw.trim();
        if (required && content.isEmpty()) {
            throw new BusinessException(appMessages.get("app.timeLetter.error.bodyEmpty"));
        }
        if (content.length() > properties.getBodyMaxLength()) {
            throw new BusinessException(appMessages.get("app.timeLetter.error.bodyTooLong"));
        }
        return content;
    }

    /**
     * 正文必填时，空内容直接抛业务异常。
     */
    private void assertBodyPresentIfRequired(boolean required) {
        if (!required) {
            return;
        }
        throw new BusinessException(appMessages.get("app.timeLetter.error.bodyEmpty"));
    }

    private void validateDeliveryDate(LocalDate deliveryDate, String deliveryTz) {
        if (deliveryDate == null) {
            throw new BusinessException(appMessages.get("app.timeLetter.error.deliveryDateRequired"));
        }
        ZoneId zone = resolveZone(deliveryTz);
        LocalDate today = ZonedDateTime.now(zone).toLocalDate();
        if (deliveryDate.isBefore(today)) {
            throw new BusinessException(appMessages.get("app.timeLetter.error.deliveryDatePast"));
        }
        LocalDate max = today.plusYears(properties.getMaxDeliveryYears());
        if (deliveryDate.isAfter(max)) {
            throw new BusinessException(appMessages.get("app.timeLetter.error.deliveryDateTooFar"));
        }
    }

    private ZoneId resolveZone(String deliveryTz) {
        if (!StringUtils.hasText(deliveryTz)) {
            return ZoneId.of("UTC");
        }
        try {
            return ZoneId.of(deliveryTz.trim());
        } catch (Exception e) {
            throw new BusinessException(appMessages.get("app.timeLetter.error.invalidTimezone"));
        }
    }

    private TimeLetterDomain loadOwnedDraft(long userId, long draftId) {
        TimeLetterDomain d = timeLetterService.getById(draftId);
        if (d == null || d.isDelFlag() || !Objects.equals(d.getSenderId(), userId)) {
            throw new BusinessException(appMessages.get("app.timeLetter.error.notFound"));
        }
        if (d.getStatus() == null || d.getStatus() != TimeLetterStatus.DRAFT.getCode()) {
            throw new BusinessException(appMessages.get("app.timeLetter.error.notDraft"));
        }
        return d;
    }

    private TimeLetterDomain loadOwnedPending(long userId, long letterId) {
        TimeLetterDomain d = timeLetterService.getById(letterId);
        if (d == null || d.isDelFlag() || !Objects.equals(d.getSenderId(), userId)) {
            throw new BusinessException(appMessages.get("app.timeLetter.error.notFound"));
        }
        if (d.getStatus() == null || d.getStatus() != TimeLetterStatus.PENDING.getCode()) {
            throw new BusinessException(appMessages.get("app.timeLetter.error.notPending"));
        }
        return d;
    }

    private TimeLetterDomain loadAccessible(long userId, long letterId) {
        TimeLetterDomain d = timeLetterService.getById(letterId);
        if (d == null || d.isDelFlag()) {
            throw new BusinessException(appMessages.get("app.timeLetter.error.notFound"));
        }
        if (StringUtils.hasText(d.getTakedownReason())) {
            throw new BusinessException(appMessages.get("app.timeLetter.error.takedown"));
        }
        if (Objects.equals(d.getSenderId(), userId)) {
            return d;
        }
        if (!isRecipient(userId, d)) {
            throw new BusinessException(appMessages.get("app.timeLetter.error.noPermission"));
        }
        // 收件人不可查看仍在途（PENDING）的时光信
        if (d.getStatus() != null && d.getStatus() == TimeLetterStatus.PENDING.getCode()) {
            throw new BusinessException(appMessages.get("app.timeLetter.error.notDelivered"));
        }
        return d;
    }

    private static boolean isRecipient(long userId, TimeLetterDomain d) {
        if (d.getRecipientId() != null) {
            return Objects.equals(d.getRecipientId(), userId);
        }
        return Objects.equals(d.getSenderId(), userId);
    }

    private static boolean canViewBody(TimeLetterDomain d, long userId) {
        int st = d.getStatus() != null ? d.getStatus() : 0;
        if (st == TimeLetterStatus.DRAFT.getCode()) {
            return Objects.equals(d.getSenderId(), userId);
        }
        if (Objects.equals(d.getSenderId(), userId) && st == TimeLetterStatus.PENDING.getCode()) {
            return false;
        }
        if (st == TimeLetterStatus.PENDING.getCode()) {
            return false;
        }
        return isRecipient(userId, d) || Objects.equals(d.getSenderId(), userId);
    }

    private void applyDraftFields(
            TimeLetterDomain d, ResolvedRecipient resolved, String content, TimeLetterDraftSaveInDto body) {
        d.setRecipientId(resolved.recipientId);
        d.setRecipientType(resolved.recipientType);
        d.setBody(content);
        d.setContentTag(trimOrNull(body.getContentTag()));
        d.setEmotionTag(trimOrNull(body.getEmotionTag()));
        d.setPaperTheme(trimOrNull(body.getPaperTheme()));
        d.setPaperColor(trimOrNull(body.getPaperColor()));
        d.setDeliveryDate(body.getDeliveryDate());
        d.setDeliveryTz(resolveZone(body.getDeliveryTz()).getId());
        d.setWriterCity(trimOrNull(body.getWriterCity()));
        d.setWriteDurationSec(body.getWriteDurationSec());
    }

    private void applySealFields(
            TimeLetterDomain d,
            ResolvedRecipient resolved,
            String content,
            TimeLetterSealInDto body,
            LocalDateTime now,
            int stampCost) {
        d.setRecipientId(resolved.recipientId);
        d.setRecipientType(resolved.recipientType);
        d.setBody(content);
        d.setContentTag(trimOrNull(body.getContentTag()));
        d.setEmotionTag(trimOrNull(body.getEmotionTag()));
        d.setPaperTheme(trimOrNull(body.getPaperTheme()));
        d.setPaperColor(trimOrNull(body.getPaperColor()));
        d.setDeliveryDate(body.getDeliveryDate());
        d.setDeliveryTz(resolveZone(body.getDeliveryTz()).getId());
        d.setWriterCity(trimOrNull(body.getWriterCity()));
        d.setWriteDurationSec(body.getWriteDurationSec());
        d.setStatus(TimeLetterStatus.PENDING.getCode());
        d.setSealedAt(now);
        d.setCancelDeadlineAt(now.plusHours(properties.getCancelWindowHours()));
        d.setStampCost(stampCost);
        d.setSealRequestId(body.getSealRequestId().trim());
        UserDTO sender = userService.findById(d.getSenderId());
        if (sender != null) {
            Map<String, Object> snap = new HashMap<>();
            snap.put("nickname", sender.getNickname());
            snap.put("avatarUrl", sender.getAvatarUrl());
            d.setSenderSnapshotJson(snap);
        }
    }


    private TimeLetterListItemVO toListItem(TimeLetterDomain d, long userId, Boolean outbox) {
        Long peerId = resolvePeerUserId(d, userId, outbox);
        UserDTO peer = peerId != null ? userService.findById(peerId) : null;
        String body = d.getBody() != null ? d.getBody() : "";
        boolean hideBody = Objects.equals(d.getSenderId(), userId)
                && d.getStatus() != null
                && d.getStatus() == TimeLetterStatus.PENDING.getCode();
        String preview = resolvePreviewBody(hideBody, body, 120);
        ZoneId zone = resolveZoneQuiet(d.getDeliveryTz());
        int daysUntil = d.getDeliveryDate() != null
                ? (int) ChronoUnit.DAYS.between(ZonedDateTime.now(zone).toLocalDate(), d.getDeliveryDate())
                : 0;
        LocalDateTime now = LocalDateTime.now();
        boolean canCancel = Objects.equals(d.getSenderId(), userId)
                && d.getStatus() != null
                && d.getStatus() == TimeLetterStatus.PENDING.getCode()
                && d.getCancelDeadlineAt() != null
                && now.isBefore(d.getCancelDeadlineAt());
        return TimeLetterListItemVO.builder()
                .id(d.getId())
                .senderId(d.getSenderId())
                .recipientId(d.getRecipientId())
                .recipientType(d.getRecipientType())
                .status(d.getStatus())
                .bodyPreview(preview)
                .deliveryDate(d.getDeliveryDate())
                .deliveryTz(d.getDeliveryTz())
                .sealedAt(d.getSealedAt())
                .deliveredAt(d.getDeliveredAt())
                .readAt(d.getReadAt())
                .cancelDeadlineAt(d.getCancelDeadlineAt())
                .starFlag(d.getStarFlag())
                .contentTag(d.getContentTag())
                .emotionTag(d.getEmotionTag())
                .peerNickname(peer != null ? peer.getNickname() : null)
                .peerAvatarUrl(peer != null ? signAvatar(userId, peer) : null)
                .daysUntilDelivery(Math.max(0, daysUntil))
                .canCancel(canCancel)
                .build();
    }

    /**
     * 按列表视角解析对端用户 ID：发件箱看收件人，收件箱看发件人，纪念册按当前用户角色取对端。
     */
    private static Long resolvePeerUserId(TimeLetterDomain d, long userId, Boolean outbox) {
        if (Boolean.TRUE.equals(outbox)) {
            return resolveSelfOrRecipientPeerId(d, userId);
        }
        if (Boolean.FALSE.equals(outbox)) {
            return d.getSenderId();
        }
        return resolveMemorialPeerUserId(d, userId);
    }

    /**
     * 纪念册：当前用户是发件人时取收件人（或自投递时取自己），否则取发件人。
     */
    private static Long resolveMemorialPeerUserId(TimeLetterDomain d, long userId) {
        if (!Objects.equals(d.getSenderId(), userId)) {
            return d.getSenderId();
        }
        return resolveSelfOrRecipientPeerId(d, userId);
    }

    /**
     * 有收件人则返回收件人，否则视为自投递返回当前用户。
     */
    private static Long resolveSelfOrRecipientPeerId(TimeLetterDomain d, long userId) {
        if (d.getRecipientId() != null) {
            return d.getRecipientId();
        }
        return userId;
    }

    /**
     * 生成列表预览正文；寄出方待投递时隐藏正文，超长截断并追加省略号。
     */
    private static String resolvePreviewBody(boolean hideBody, String body, int maxLen) {
        return cn.nine.pros.post.biz.support.TextPreviewSupport.previewOrHidden(hideBody, body, maxLen);
    }

    private TimeLetterDetailVO toDetail(TimeLetterDomain d, long userId, boolean showBody) {
        UserDTO sender = userService.findById(d.getSenderId());
        Long rid = d.getRecipientId() != null ? d.getRecipientId() : d.getSenderId();
        UserDTO recipient = rid != null ? userService.findById(rid) : null;
        String body = showBody && d.getBody() != null ? d.getBody() : null;
        int readMin = 0;
        if (showBody && StringUtils.hasText(d.getBody())) {
            readMin = Math.max(1, d.getBody().length() / 300);
        }
        LocalDateTime now = LocalDateTime.now();
        boolean canCancel = Objects.equals(d.getSenderId(), userId)
                && d.getStatus() != null
                && d.getStatus() == TimeLetterStatus.PENDING.getCode()
                && d.getCancelDeadlineAt() != null
                && now.isBefore(d.getCancelDeadlineAt());
        boolean canOpen = isRecipient(userId, d)
                && d.getStatus() != null
                && d.getStatus() == TimeLetterStatus.DELIVERED.getCode();
        return TimeLetterDetailVO.builder()
                .id(d.getId())
                .senderId(d.getSenderId())
                .recipientId(d.getRecipientId())
                .recipientType(d.getRecipientType())
                .status(d.getStatus())
                .body(body)
                .contentTag(d.getContentTag())
                .emotionTag(d.getEmotionTag())
                .paperTheme(d.getPaperTheme())
                .paperColor(d.getPaperColor())
                .deliveryDate(d.getDeliveryDate())
                .deliveryTz(d.getDeliveryTz())
                .sealedAt(d.getSealedAt())
                .deliveredAt(d.getDeliveredAt())
                .readAt(d.getReadAt())
                .cancelDeadlineAt(d.getCancelDeadlineAt())
                .starFlag(d.getStarFlag())
                .writerCity(d.getWriterCity())
                .writeDurationSec(d.getWriteDurationSec())
                .senderNickname(sender != null ? sender.getNickname() : null)
                .senderAvatarUrl(sender != null ? signAvatar(userId, sender) : null)
                .recipientNickname(recipient != null ? recipient.getNickname() : null)
                .recipientAvatarUrl(recipient != null ? signAvatar(userId, recipient) : null)
                .canCancel(canCancel)
                .canOpen(canOpen)
                .estimatedReadMinutes(readMin)
                .build();
    }

    private String signAvatar(long viewerId, UserDTO u) {
        return ossDisplayUrlService.signAvatarRefOrNull(viewerId, UserAvatarAuditSupport.publicStoredRef(u));
    }

    private static String trimOrNull(String s) {
        if (!StringUtils.hasText(s)) {
            return null;
        }
        return s.trim();
    }

    private static ZoneId resolveZoneQuiet(String tz) {
        try {
            return ZoneId.of(tz != null && !tz.isBlank() ? tz : "UTC");
        } catch (Exception e) {
            return ZoneId.of("UTC");
        }
    }

    private static int userStatus(Object status) {
        if (status instanceof Number n) {
            return n.intValue();
        }
        if (status instanceof String s) {
            return Integer.parseInt(s);
        }
        return 0;
    }

    private record ResolvedRecipient(Long recipientId, int recipientType) {}
}
