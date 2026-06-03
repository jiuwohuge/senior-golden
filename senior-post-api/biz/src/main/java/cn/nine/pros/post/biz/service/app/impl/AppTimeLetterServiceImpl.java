package cn.nine.pros.post.biz.service.app.impl;

import cn.nine.commons.basic.exception.unchecked.BusinessException;
import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.config.TimeLetterProperties;
import cn.nine.pros.post.biz.controller.app.AppPageHelper;
import cn.nine.pros.post.biz.error.PostAppErrorCodes;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.mapper.TimeLetterMapper;
import cn.nine.pros.post.biz.model.domain.TimeLetterDomain;
import cn.nine.pros.post.biz.service.app.AppBlacklistService;
import cn.nine.pros.post.biz.service.app.AppTimeLetterService;
import cn.nine.pros.post.biz.service.app.support.UserAvatarAuditSupport;
import cn.nine.pros.post.biz.service.base.FriendshipService;
import cn.nine.pros.post.biz.service.base.OssDisplayUrlService;
import cn.nine.pros.post.biz.service.base.SensitiveWordService;
import cn.nine.pros.post.biz.service.base.StampAccountService;
import cn.nine.pros.post.biz.service.base.StampTransactionService;
import cn.nine.pros.post.biz.service.base.TimeLetterService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.client.common.enums.TimeLetterRecipientType;
import cn.nine.pros.post.client.common.enums.TimeLetterStatus;
import cn.nine.pros.post.client.model.db.StampTransactionDTO;
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
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
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

@Service
@RequiredArgsConstructor
public class AppTimeLetterServiceImpl implements AppTimeLetterService {

    private static final int USER_STATUS_NORMAL = 1;

    private final TimeLetterMapper timeLetterMapper;
    private final TimeLetterService timeLetterService;
    private final UserService userService;
    private final SensitiveWordService sensitiveWordService;
    private final FriendshipService friendshipService;
    private final AppBlacklistService appBlacklistService;
    private final StampAccountService stampAccountService;
    private final StampTransactionService stampTransactionService;
    private final OssDisplayUrlService ossDisplayUrlService;
    private final TimeLetterProperties properties;
    private final AppMessages appMessages;

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

    @Override
    public TimeLetterDetailVO getDraft(long userId, long draftId) {
        return toDetail(loadOwnedDraft(userId, draftId), userId, true);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteDraft(long userId, long draftId) {
        TimeLetterDomain d = loadOwnedDraft(userId, draftId);
        d.markDeleted(userId);
        timeLetterService.updateById(d);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public TimeLetterSealResultVO seal(long userId, TimeLetterSealInDto body) {
        assertSenderActive(userId);
        if (!StringUtils.hasText(body.getSealRequestId())) {
            throw new BusinessException(appMessages.get("app.timeLetter.error.sealRequestRequired"));
        }
        TimeLetterDomain existing = timeLetterMapper.selectOne(new LambdaQueryWrapper<TimeLetterDomain>()
                .eq(TimeLetterDomain::getSenderId, userId)
                .eq(TimeLetterDomain::getSealRequestId, body.getSealRequestId().trim())
                .eq(TimeLetterDomain::isDelFlag, false)
                .last("LIMIT 1"));
        if (existing != null && existing.getStatus() != null
                && existing.getStatus() != TimeLetterStatus.DRAFT.getCode()) {
            UserDTO sender = userService.findById(userId);
            int bal = sender != null && sender.getStampsBalance() != null ? sender.getStampsBalance() : 0;
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

        int stampCost = properties.getStampCost();
        UserDTO sender = userService.findById(userId);
        int oldBal = sender != null && sender.getStampsBalance() != null ? sender.getStampsBalance() : 0;
        if (oldBal < stampCost) {
            throw new BusinessException(
                    PostAppErrorCodes.STAMP_INSUFFICIENT,
                    appMessages.get("app.error.stamp.insufficientTimeLetter"));
        }

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
            throw new BusinessException(appMessages.get("app.timeLetter.error.sameDayDuplicate"));
        }

        int newBal = oldBal - stampCost;
        boolean patched = stampAccountService.tryDecrementBalance(userId, oldBal, stampCost, now, userId);
        if (!patched) {
            throw new BusinessException(appMessages.get("app.error.stamp.debitFailed"));
        }
        StampTransactionDTO tx = new StampTransactionDTO();
        tx.setUserId(userId);
        tx.setChangeAmount(-stampCost);
        tx.setBalanceAfter(newBal);
        tx.setReason(appMessages.get("app.stamp.reason.timeLetterSeal"));
        tx.setRefId(d.getId());
        stampTransactionService.upsert(tx);

        return TimeLetterSealResultVO.builder()
                .id(d.getId())
                .status(d.getStatus())
                .deliveryDate(d.getDeliveryDate())
                .cancelDeadlineAt(d.getCancelDeadlineAt())
                .stampCost(stampCost)
                .stampBalanceAfter(newBal)
                .build();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void cancel(long userId, long letterId) {
        TimeLetterDomain d = loadOwnedPending(userId, letterId);
        LocalDateTime now = LocalDateTime.now();
        if (d.getCancelDeadlineAt() == null || now.isAfter(d.getCancelDeadlineAt())) {
            throw new BusinessException(appMessages.get("app.timeLetter.error.cancelWindowExpired"));
        }
        boolean ok = timeLetterService.update(new LambdaUpdateWrapper<TimeLetterDomain>()
                .eq(TimeLetterDomain::getId, letterId)
                .eq(TimeLetterDomain::getSenderId, userId)
                .eq(TimeLetterDomain::isDelFlag, false)
                .eq(TimeLetterDomain::getStatus, TimeLetterStatus.PENDING.getCode())
                .set(TimeLetterDomain::getStatus, TimeLetterStatus.CANCELLED.getCode())
                .set(TimeLetterDomain::getCancelledAt, now)
                .set(TimeLetterDomain::getUpdatedAt, now)
                .set(TimeLetterDomain::getUpdatedBy, userId));
        if (!ok) {
            throw new BusinessException(appMessages.get("app.timeLetter.error.stateChanged"));
        }
        refundStamp(userId, d.getStampCost(), letterId, appMessages.get("app.stamp.reason.timeLetterCancelRefund"));
    }

    @Override
    public PageData<TimeLetterListItemVO> outboxPage(long userId, TimeLetterPageInDto body) {
        PageQuery pq = AppPageHelper.normalize(body == null ? null : body.getPage());
        LambdaQueryWrapper<TimeLetterDomain> qw = new LambdaQueryWrapper<TimeLetterDomain>()
                .eq(TimeLetterDomain::getSenderId, userId)
                .eq(TimeLetterDomain::isDelFlag, false)
                .ne(TimeLetterDomain::getStatus, TimeLetterStatus.DRAFT.getCode());
        if (body != null && Boolean.TRUE.equals(body.getStarredOnly())) {
            qw.eq(TimeLetterDomain::getStarFlag, true);
        }
        qw.orderByDesc(TimeLetterDomain::getCreatedAt);
        return pageList(userId, pq, qw, true);
    }

    @Override
    public PageData<TimeLetterListItemVO> inboxPage(long userId, TimeLetterPageInDto body) {
        PageQuery pq = AppPageHelper.normalize(body == null ? null : body.getPage());
        LambdaQueryWrapper<TimeLetterDomain> qw = new LambdaQueryWrapper<TimeLetterDomain>()
                .and(w -> w.eq(TimeLetterDomain::getRecipientId, userId)
                        .or(o -> o.isNull(TimeLetterDomain::getRecipientId)
                                .eq(TimeLetterDomain::getSenderId, userId)))
                .eq(TimeLetterDomain::isDelFlag, false)
                .in(TimeLetterDomain::getStatus,
                        TimeLetterStatus.DELIVERED.getCode(),
                        TimeLetterStatus.READ.getCode())
                .orderByDesc(TimeLetterDomain::getDeliveredAt);
        return pageList(userId, pq, qw, false);
    }

    @Override
    public PageData<TimeLetterListItemVO> memorialPage(long userId, TimeLetterPageInDto body) {
        PageQuery pq = AppPageHelper.normalize(body == null ? null : body.getPage());
        LambdaQueryWrapper<TimeLetterDomain> qw = new LambdaQueryWrapper<TimeLetterDomain>()
                .eq(TimeLetterDomain::isDelFlag, false)
                .eq(TimeLetterDomain::getStatus, TimeLetterStatus.READ.getCode())
                .and(w -> w.eq(TimeLetterDomain::getSenderId, userId)
                        .or().eq(TimeLetterDomain::getRecipientId, userId)
                        .or(o -> o.isNull(TimeLetterDomain::getRecipientId)
                                .eq(TimeLetterDomain::getSenderId, userId)));
        if (body != null && Boolean.TRUE.equals(body.getStarredOnly())) {
            qw.eq(TimeLetterDomain::getStarFlag, true);
        }
        qw.orderByDesc(TimeLetterDomain::getReadAt);
        return pageList(userId, pq, qw, null);
    }

    @Override
    public TimeLetterDetailVO getDetail(long userId, long letterId) {
        TimeLetterDomain d = loadAccessible(userId, letterId);
        boolean showBody = canViewBody(d, userId);
        return toDetail(d, userId, showBody);
    }

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
        boolean ok = timeLetterService.update(new LambdaUpdateWrapper<TimeLetterDomain>()
                .eq(TimeLetterDomain::getId, letterId)
                .eq(TimeLetterDomain::isDelFlag, false)
                .eq(TimeLetterDomain::getStatus, TimeLetterStatus.DELIVERED.getCode())
                .set(TimeLetterDomain::getStatus, TimeLetterStatus.READ.getCode())
                .set(TimeLetterDomain::getReadAt, now)
                .set(TimeLetterDomain::getUpdatedAt, now)
                .set(TimeLetterDomain::getUpdatedBy, userId));
        if (!ok) {
            throw new BusinessException(appMessages.get("app.timeLetter.error.stateChanged"));
        }
        d = timeLetterMapper.selectById(letterId);
        return toDetail(d, userId, true);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void toggleStar(long userId, long letterId) {
        TimeLetterDomain d = loadAccessible(userId, letterId);
        if (d.getStatus() == null || d.getStatus() != TimeLetterStatus.READ.getCode()) {
            throw new BusinessException(appMessages.get("app.timeLetter.error.starReadOnly"));
        }
        boolean next = !Boolean.TRUE.equals(d.getStarFlag());
        timeLetterService.update(new LambdaUpdateWrapper<TimeLetterDomain>()
                .eq(TimeLetterDomain::getId, letterId)
                .set(TimeLetterDomain::getStarFlag, next)
                .set(TimeLetterDomain::getUpdatedAt, LocalDateTime.now())
                .set(TimeLetterDomain::getUpdatedBy, userId));
    }

    @Override
    public TimeLetterStatsVO stats(long userId) {
        long inFlight = timeLetterService.count(new LambdaQueryWrapper<TimeLetterDomain>()
                .eq(TimeLetterDomain::getSenderId, userId)
                .eq(TimeLetterDomain::isDelFlag, false)
                .eq(TimeLetterDomain::getStatus, TimeLetterStatus.PENDING.getCode()));
        long unread = timeLetterService.count(new LambdaQueryWrapper<TimeLetterDomain>()
                .eq(TimeLetterDomain::isDelFlag, false)
                .eq(TimeLetterDomain::getStatus, TimeLetterStatus.DELIVERED.getCode())
                .and(w -> w.eq(TimeLetterDomain::getRecipientId, userId)
                        .or(o -> o.isNull(TimeLetterDomain::getRecipientId)
                                .eq(TimeLetterDomain::getSenderId, userId))));
        long memorial = timeLetterService.count(new LambdaQueryWrapper<TimeLetterDomain>()
                .eq(TimeLetterDomain::isDelFlag, false)
                .eq(TimeLetterDomain::getStatus, TimeLetterStatus.READ.getCode())
                .and(w -> w.eq(TimeLetterDomain::getSenderId, userId)
                        .or().eq(TimeLetterDomain::getRecipientId, userId)
                        .or(o -> o.isNull(TimeLetterDomain::getRecipientId)
                                .eq(TimeLetterDomain::getSenderId, userId))));
        LocalDate today = LocalDate.now();
        LocalDateTime todayStart = today.atStartOfDay();
        LocalDateTime tomorrowStart = today.plusDays(1).atStartOfDay();
        long todayDelivered = timeLetterService.count(new LambdaQueryWrapper<TimeLetterDomain>()
                .eq(TimeLetterDomain::isDelFlag, false)
                .eq(TimeLetterDomain::getStatus, TimeLetterStatus.DELIVERED.getCode())
                .and(w -> w.eq(TimeLetterDomain::getRecipientId, userId)
                        .or(o -> o.isNull(TimeLetterDomain::getRecipientId)
                                .eq(TimeLetterDomain::getSenderId, userId)))
                .ge(TimeLetterDomain::getDeliveredAt, todayStart)
                .lt(TimeLetterDomain::getDeliveredAt, tomorrowStart));
        return TimeLetterStatsVO.builder()
                .inFlightCount((int) inFlight)
                .deliveredUnreadCount((int) unread)
                .memorialCount((int) memorial)
                .todayDeliveredCount((int) todayDelivered)
                .build();
    }

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

    @Override
    public List<TimeLetterRecentRecipientVO> recentRecipients(long userId) {
        List<TimeLetterDomain> rows = timeLetterMapper.selectList(new LambdaQueryWrapper<TimeLetterDomain>()
                .eq(TimeLetterDomain::getSenderId, userId)
                .eq(TimeLetterDomain::isDelFlag, false)
                .isNotNull(TimeLetterDomain::getRecipientId)
                .ne(TimeLetterDomain::getStatus, TimeLetterStatus.DRAFT.getCode())
                .orderByDesc(TimeLetterDomain::getSealedAt)
                .last("LIMIT 30"));
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
            long userId, PageQuery pq, LambdaQueryWrapper<TimeLetterDomain> qw, Boolean outbox) {
        Page<TimeLetterDomain> p = timeLetterService.page(AppPageHelper.mpPage(pq), qw);
        List<TimeLetterListItemVO> list = p.getRecords().stream()
                .map(d -> toListItem(d, userId, outbox))
                .collect(Collectors.toList());
        return AppPageHelper.pageData(pq, p, list);
    }

    private void assertSealLimits(long userId, Long recipientId, LocalDate deliveryDate) {
        LocalDateTime dayStart = LocalDate.now().atStartOfDay();
        long todayCount = timeLetterService.count(new LambdaQueryWrapper<TimeLetterDomain>()
                .eq(TimeLetterDomain::getSenderId, userId)
                .eq(TimeLetterDomain::isDelFlag, false)
                .ge(TimeLetterDomain::getSealedAt, dayStart)
                .ne(TimeLetterDomain::getStatus, TimeLetterStatus.DRAFT.getCode())
                .ne(TimeLetterDomain::getStatus, TimeLetterStatus.CANCELLED.getCode()));
        if (todayCount >= properties.getDailyCreateLimit()) {
            throw new BusinessException(appMessages.get("app.timeLetter.error.dailyLimit"));
        }
        long inFlight = timeLetterService.count(new LambdaQueryWrapper<TimeLetterDomain>()
                .eq(TimeLetterDomain::getSenderId, userId)
                .eq(TimeLetterDomain::isDelFlag, false)
                .eq(TimeLetterDomain::getStatus, TimeLetterStatus.PENDING.getCode()));
        if (inFlight >= properties.getInFlightLimit()) {
            throw new BusinessException(appMessages.get("app.timeLetter.error.inFlightLimit"));
        }
        if (recipientId != null) {
            LocalDateTime since30 = LocalDateTime.now().minusDays(30);
            long toRecipient = timeLetterService.count(new LambdaQueryWrapper<TimeLetterDomain>()
                    .eq(TimeLetterDomain::getSenderId, userId)
                    .eq(TimeLetterDomain::getRecipientId, recipientId)
                    .eq(TimeLetterDomain::isDelFlag, false)
                    .ge(TimeLetterDomain::getSealedAt, since30)
                    .ne(TimeLetterDomain::getStatus, TimeLetterStatus.DRAFT.getCode())
                    .ne(TimeLetterDomain::getStatus, TimeLetterStatus.CANCELLED.getCode()));
            if (toRecipient >= properties.getRecipient30dLimit()) {
                throw new BusinessException(appMessages.get("app.timeLetter.error.recipient30dLimit"));
            }
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
            if (required) {
                throw new BusinessException(appMessages.get("app.timeLetter.error.bodyEmpty"));
            }
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
        TimeLetterDomain d = timeLetterMapper.selectById(draftId);
        if (d == null || d.isDelFlag() || !Objects.equals(d.getSenderId(), userId)) {
            throw new BusinessException(appMessages.get("app.timeLetter.error.notFound"));
        }
        if (d.getStatus() == null || d.getStatus() != TimeLetterStatus.DRAFT.getCode()) {
            throw new BusinessException(appMessages.get("app.timeLetter.error.notDraft"));
        }
        return d;
    }

    private TimeLetterDomain loadOwnedPending(long userId, long letterId) {
        TimeLetterDomain d = timeLetterMapper.selectById(letterId);
        if (d == null || d.isDelFlag() || !Objects.equals(d.getSenderId(), userId)) {
            throw new BusinessException(appMessages.get("app.timeLetter.error.notFound"));
        }
        if (d.getStatus() == null || d.getStatus() != TimeLetterStatus.PENDING.getCode()) {
            throw new BusinessException(appMessages.get("app.timeLetter.error.notPending"));
        }
        return d;
    }

    private TimeLetterDomain loadAccessible(long userId, long letterId) {
        TimeLetterDomain d = timeLetterMapper.selectById(letterId);
        if (d == null || d.isDelFlag()) {
            throw new BusinessException(appMessages.get("app.timeLetter.error.notFound"));
        }
        if (StringUtils.hasText(d.getTakedownReason())) {
            throw new BusinessException(appMessages.get("app.timeLetter.error.takedown"));
        }
        if (Objects.equals(d.getSenderId(), userId)) {
            return d;
        }
        if (isRecipient(userId, d)) {
            if (d.getStatus() != null && d.getStatus() == TimeLetterStatus.PENDING.getCode()) {
                throw new BusinessException(appMessages.get("app.timeLetter.error.notDelivered"));
            }
            return d;
        }
        throw new BusinessException(appMessages.get("app.timeLetter.error.noPermission"));
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

    private void refundStamp(long userId, Integer stampCost, long refId, String reason) {
        int cost = stampCost != null ? stampCost : 0;
        if (cost <= 0) {
            return;
        }
        LocalDateTime now = LocalDateTime.now();
        stampAccountService.addBalance(userId, cost, now, userId);
        UserDTO sender = userService.findById(userId);
        int balanceAfter = sender != null && sender.getStampsBalance() != null
                ? sender.getStampsBalance() + cost
                : cost;
        StampTransactionDTO tx = new StampTransactionDTO();
        tx.setUserId(userId);
        tx.setChangeAmount(cost);
        tx.setBalanceAfter(balanceAfter);
        tx.setReason(reason);
        tx.setRefId(refId);
        stampTransactionService.upsert(tx);
    }

    private TimeLetterListItemVO toListItem(TimeLetterDomain d, long userId, Boolean outbox) {
        Long peerId;
        if (Boolean.TRUE.equals(outbox)) {
            peerId = d.getRecipientId() != null ? d.getRecipientId() : userId;
        } else if (Boolean.FALSE.equals(outbox)) {
            peerId = d.getSenderId();
        } else {
            peerId = Objects.equals(d.getSenderId(), userId)
                    ? (d.getRecipientId() != null ? d.getRecipientId() : userId)
                    : d.getSenderId();
        }
        UserDTO peer = peerId != null ? userService.findById(peerId) : null;
        String body = d.getBody() != null ? d.getBody() : "";
        boolean hideBody = Objects.equals(d.getSenderId(), userId)
                && d.getStatus() != null
                && d.getStatus() == TimeLetterStatus.PENDING.getCode();
        String preview = hideBody ? "" : (body.length() > 120 ? body.substring(0, 120) + "…" : body);
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
        String ref = UserAvatarAuditSupport.publicStoredRef(u);
        if (!StringUtils.hasText(ref)) {
            return null;
        }
        return ossDisplayUrlService.signAvatarForViewer(viewerId, ref);
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
