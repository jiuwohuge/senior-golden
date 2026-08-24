package cn.nine.pros.post.biz.service.biz.impl;

import cn.nine.commons.basic.exception.unchecked.BusinessException;
import cn.nine.pros.post.biz.ai.LetterAssistantService;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.moderation.ModerationVerdict;
import cn.nine.pros.post.biz.moderation.TextModerationProvider;
import cn.nine.pros.post.biz.model.domain.CountryDomain;
import cn.nine.pros.post.biz.model.domain.FriendshipDomain;
import cn.nine.pros.post.biz.model.domain.LetterDomain;
import cn.nine.pros.post.biz.service.biz.AppBlacklistService;
import cn.nine.pros.post.biz.service.biz.AppCommerceBizService;
import cn.nine.pros.post.biz.service.biz.AppMailboxService;
import cn.nine.pros.post.biz.service.biz.AppRelationBizService;
import cn.nine.pros.post.biz.service.biz.WritingStyleService;
import cn.nine.pros.post.biz.service.base.ActionService;
import cn.nine.pros.post.biz.service.base.DailyQuotaClaimService;
import cn.nine.pros.post.biz.service.base.ConfigService;
import cn.nine.pros.post.biz.service.base.CountryService;
import cn.nine.pros.post.biz.service.base.FriendshipService;
import cn.nine.pros.post.biz.service.base.LetterService;
import cn.nine.pros.post.biz.service.base.SensitiveWordService;
import cn.nine.pros.post.biz.service.base.TimeLetterService;
import cn.nine.pros.post.biz.service.base.OssDisplayUrlService;
import cn.nine.pros.post.biz.service.biz.support.DeliveryDelayCalculator;
import cn.nine.pros.post.biz.service.biz.support.DailyQuotaSupport;
import cn.nine.pros.post.biz.service.biz.support.LetterTopicSupport;
import cn.nine.pros.post.biz.service.biz.support.UserAvatarAuditSupport;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.client.common.constant.BehaviorActionTypes;
import cn.nine.pros.post.client.common.enums.LetterAuditStatus;
import cn.nine.pros.post.client.common.enums.LetterBizStatus;
import cn.nine.pros.post.client.common.enums.LetterMode;
import cn.nine.pros.post.client.common.enums.LetterPhysicalType;
import cn.nine.pros.post.client.common.enums.LetterSendMode;
import cn.nine.pros.post.client.model.db.UserDTO;
import cn.nine.pros.post.client.model.input.app.AppLetterAssistantInDto;
import cn.nine.pros.post.client.model.input.app.AppSendLetterInDto;
import cn.nine.pros.post.client.model.json.LetterContentMeta;
import cn.nine.pros.post.client.model.out.AcceptPostalContactResultVO;
import cn.nine.pros.post.client.model.out.AppLetterAssistantVO;
import cn.nine.pros.post.client.model.out.AppPublicUserVO;
import cn.nine.pros.post.client.model.out.PenpalRequestResultVO;
import cn.nine.pros.post.client.model.out.RelationSnapshotVO;
import cn.nine.pros.post.client.model.out.LetterSyncResultVO;
import cn.nine.pros.post.client.model.out.MailboxFriendItemVO;
import cn.nine.pros.post.client.model.out.MailboxLetterItemVO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

/**
 * App 标准信箱业务：收件箱/归档/发信/早开/好友列表。
 * <p>写路径（发信、早开、接受邮缘）落库后打 INFO；敏感词拒绝由 SensitiveWordService 抛错不落库。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AppMailboxServiceImpl implements AppMailboxService {

    private static final int USER_STATUS_NORMAL = 1;
    private static final String LETTER_MAX_LENGTH_KEY = "letter.max_length";
    private static final int DEFAULT_MAX_LETTER_LENGTH = 5000;
    private static final String AUDIT_AUTO_APPROVE_SEC = "audit.auto_approve_seconds";

    private final LetterService letterService;
    private final FriendshipService friendshipService;
    private final UserService userService;
    private final SensitiveWordService sensitiveWordService;
    private final ConfigService configService;
    private final ActionService actionService;
    private final OssDisplayUrlService ossDisplayUrlService;
    private final AppBlacklistService appBlacklistService;
    private final WritingStyleService writingStyleService;
    private final DeliveryDelayCalculator deliveryDelayCalculator;
    private final AppMessages appMessages;
    private final AppRelationBizService appRelationBizService;
    private final AppCommerceBizService appCommerceBizService;
    private final CountryService countryService;
    private final TextModerationProvider textModerationProvider;
    private final DailyQuotaClaimService dailyQuotaClaimService;
    private final TimeLetterService timeLetterService;
    private final LetterAssistantService letterAssistantService;
    private final LetterTopicSupport letterTopicSupport;

    /**
     * 邮政收件箱：本人相关且未读的信件列表（含 POST_OFFICE 入池仅发件人可见）。
     * <p>前置：userId 已登录；无写库副作用。
     */
    @Override
    public List<MailboxLetterItemVO> listPostalInbox(Long userId) {
        List<LetterDomain> letters = loadLettersForUser(userId, null, 500);
        List<MailboxLetterItemVO> out = new ArrayList<>();
        for (LetterDomain l : letters) {
            if (!includeInPostalInbox(l, userId)) {
                continue;
            }
            out.add(toItem(l, userId, false));
        }
        return out;
    }

    /**
     * 增量同步信箱：返回 since 之后、仍属邮政收件箱可见范围的信件及 serverTime。
     * <p>前置：userId 已登录；无写库副作用。
     */
    @Override
    public LetterSyncResultVO sync(Long userId, LocalDateTime since) {
        List<LetterDomain> letters = loadLettersForUser(userId, since, 500);
        List<MailboxLetterItemVO> items = letters.stream()
                .filter(l -> includeInPostalInbox(l, userId))
                .map(l -> toItem(l, userId, false))
                .collect(Collectors.toList());
        return LetterSyncResultVO.builder()
                .letters(items)
                .serverTime(LocalDateTime.now())
                .build();
    }

    /**
     * 归档列表：用户作为收/发件人的全部未删信件（含已读）。
     * <p>前置：userId 已登录；无写库副作用。
     */
    @Override
    public List<MailboxLetterItemVO> listArchive(Long userId) {
        return loadLettersForUser(userId, null, 500).stream()
                .map(l -> toItem(l, userId, false))
                .collect(Collectors.toList());
    }

    @Override
    public List<MailboxLetterItemVO> listReceived(Long userId) {
        return letterService.listReceivedForUser(userId, 500).stream()
                .map(l -> toItem(l, userId, false))
                .collect(Collectors.toList());
    }

    @Override
    public List<MailboxLetterItemVO> listSent(Long userId) {
        return letterService.listSentForUser(userId, 500).stream()
                .map(l -> toItem(l, userId, false))
                .collect(Collectors.toList());
    }

    /**
     * 兼容旧路径：基于信件发起笔友申请（§10.4）。
     */
    @Override
    public AcceptPostalContactResultVO acceptPostalContact(Long actorUserId, Long letterId) {
        PenpalRequestResultVO req = appRelationBizService.createPenpalRequestFromLetter(actorUserId, letterId);
        log.info("penpal request via accept-postal, actorUserId={}, letterId={}, requestId={}",
                actorUserId, letterId, req.getRequestId());
        return AcceptPostalContactResultVO.builder()
                .requestId(req.getRequestId())
                .peerUserId(req.getPeerUserId())
                .build();
    }

    /**
     * 发送标准信：DIRECT 入运输轨或 POST_OFFICE 入匹配池；回信强制 DIRECT。
     * <p>前置：发件人状态正常、正文非空且过敏感词、DIRECT 收件人合法且未互黑。
     * <p>副作用：写 letter、重算写作风格；事务边界为本方法。
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public MailboxLetterItemVO sendLetter(long fromUserId, AppSendLetterInDto body) {
        Long parentLetterId = body.getParentLetterId();
        LetterMode mode = resolveSendMode(body, parentLetterId);
        Long toUserId;
        if (parentLetterId != null) {
            toUserId = resolveReplyRecipientId(fromUserId, parentLetterId, body);
            mode = LetterMode.DIRECT;
        } else if (mode == LetterMode.DIRECT) {
            toUserId = requireDirectRecipientId(fromUserId, body);
        } else if (mode == LetterMode.POST_OFFICE) {
            // 入池：无收件人；匹配留 M3
            toUserId = null;
        } else {
            throw new BusinessException(appMessages.get("app.error.letter.modeInvalid"));
        }

        String raw = body.getContent();
        if (!StringUtils.hasText(raw)) {
            throw new BusinessException(appMessages.get("app.error.letter.contentEmpty"));
        }
        String content = raw.trim();
        int maxLen = configService.getInt(LETTER_MAX_LENGTH_KEY, DEFAULT_MAX_LETTER_LENGTH);
        if (content.length() > maxLen) {
            throw new BusinessException(appMessages.get("app.error.letter.contentTooLong"));
        }
        // 敏感词硬拦截：拒绝则抛错不落库
        sensitiveWordService.assertPlainTextAllowed(content);
        TextModerationProvider.TextModerationResult moderation = textModerationProvider.auditText(content);
        if (moderation.verdict() == ModerationVerdict.REJECT) {
            throw new BusinessException(appMessages.get("app.error.letter.contentRejected"));
        }

        String skinId = normalizeMetaId(body.getSkinId(), "default");
        String fontId = normalizeMetaId(body.getFontId(), "default");
        String templateId = normalizeMetaId(body.getTemplateId(), "default");
        // 字号档仅存 meta，不校验商城权益（非付费商品）
        String fontSizeTier = body.getFontSizeTier();
        appCommerceBizService.assertLetterContentEntitlements(fromUserId, skinId, fontId, templateId);
        // M6：产品面废弃平邮/挂号，统一 STANDARD；速度仅 §6.1
        LetterPhysicalType physicalType = LetterPhysicalType.STANDARD;

        UserDTO sender = userService.findById(fromUserId);
        if (sender == null || userStatus(sender.getStatus()) != USER_STATUS_NORMAL) {
            throw new BusinessException(appMessages.get("app.error.sender.statusBad"));
        }
        assertDailyQuota(fromUserId, sender);

        UserDTO toUser = loadValidatedRecipient(fromUserId, toUserId);
        Integer topicTagId = letterTopicSupport.requireLetterTopicIdOrNull(fromUserId, body.getTopicTagId());

        LocalDateTime now = LocalDateTime.now();
        LetterDomain letter = new LetterDomain();
        letter.setFromUserId(fromUserId);
        letter.setToUserId(toUserId);
        letter.setContent(content);
        letter.setParentLetterId(parentLetterId);
        letter.setMode(mode.getCode());
        letter.setTopicTagId(topicTagId);
        letter.setAuditStatus(LetterAuditStatus.PENDING_REVIEW.getCode());
        letter.setLetterType(physicalType.getCode());
        LetterContentMeta contentMeta = LetterContentMeta.of(skinId, fontId, fontSizeTier, templateId);
        letter.setContentMetaJson(contentMeta);
        letter.setSendMode(LetterSendMode.STANDARD_POST.getCode());
        log.info(
                "letter content meta prepared, fromUserId={}, skinId={}, fontId={}, fontSizeTier={}",
                fromUserId,
                skinId,
                fontId,
                contentMeta.fontSizeTierOrDefault());

        if (mode == LetterMode.POST_OFFICE) {
            letter.setStatus(LetterBizStatus.PENDING.getCode());
            letter.setExpectedArrivalTime(null);
            letter.setActualArrivalTime(null);
            log.info("POST_OFFICE letter pooled, fromUserId={}", fromUserId);
        } else {
            LocalDateTime eta = deliveryDelayCalculator.expectedArrival(now, sender, toUser);
            letter.setStatus(LetterBizStatus.DELIVERING.getCode());
            letter.setExpectedArrivalTime(eta);
            letter.setActualArrivalTime(null);
            log.info("DIRECT letter queued, fromUserId={}, toUserId={}, eta={}", fromUserId, toUserId, eta);
        }

        letter.initAudit(fromUserId);
        letterService.save(letter);
        if (moderation.verdict() == ModerationVerdict.PASS) {
            maybeAutoApproveOnSend(letter.getId(), now);
        } else if (moderation.verdict() == ModerationVerdict.SKIPPED) {
            maybeAutoApproveOnSend(letter.getId(), now);
        }
        writingStyleService.recompute(fromUserId);
        if (!Boolean.TRUE.equals(sender.getFirstLetterDone())) {
            userService.markFirstLetterDone(fromUserId);
            log.info("first letter marked done, userId={}, letterId={}", fromUserId, letter.getId());
        }
        String actionType = parentLetterId != null
                ? BehaviorActionTypes.REPLY_LETTER
                : BehaviorActionTypes.SEND_LETTER;
        actionService.recordEvent(
                fromUserId, actionType, BehaviorActionTypes.TARGET_LETTER, letter.getId(), null);
        log.info("letter sent, fromUserId={}, letterId={}, mode={}, topicTagId={}",
                fromUserId, letter.getId(), mode.getCode(), topicTagId);

        LetterDomain saved = letterService.getById(letter.getId());
        return toItem(saved, fromUserId, false);
    }

    /** 非 VIP：未超当日发信上限（额度静默发放，不再要求先领取）。 */
    private void assertDailyQuota(long fromUserId, UserDTO sender) {
        if (Boolean.TRUE.equals(sender.getIsVip())) {
            return;
        }
        DailyQuotaSupport.Snapshot snap = DailyQuotaSupport.resolve(
                fromUserId, sender, configService, dailyQuotaClaimService, letterService, timeLetterService);
        if (snap.remaining() <= 0) {
            log.info("letter send rejected: daily quota exhausted, userId={}, sent={}, cap={}",
                    fromUserId, snap.sentToday(), snap.cap());
            throw new BusinessException(appMessages.get("app.error.letter.dailyQuotaExhausted"));
        }
    }

    /** auto_approve_seconds≤0 时立即放行，便于 DIRECT 进入投递轨。 */
    private void maybeAutoApproveOnSend(Long letterId, LocalDateTime now) {
        if (letterId == null) {
            return;
        }
        int seconds = configService.getInt(AUDIT_AUTO_APPROVE_SEC, 0);
        if (seconds > 0) {
            return;
        }
        letterService.approveAudit(letterId, now, 0L);
    }

    /** 推断发送模式：显式 mode > 回信/有收件人 DIRECT > 默认 POST_OFFICE。 */
    private static LetterMode resolveSendMode(AppSendLetterInDto body, Long parentLetterId) {
        LetterMode explicit = LetterMode.fromCode(body.getMode());
        if (explicit != null) {
            return explicit;
        }
        if (parentLetterId != null || body.getToUserId() != null) {
            return LetterMode.DIRECT;
        }
        return LetterMode.POST_OFFICE;
    }

    /**
     * 回信路由：仅原信收件人可回，收件人固定为原信发件人。
     */
    private Long resolveReplyRecipientId(long fromUserId, Long parentLetterId, AppSendLetterInDto body) {
        LetterDomain parent = letterService.getById(parentLetterId);
        if (parent == null || parent.isDelFlag()) {
            throw new BusinessException(appMessages.get("app.error.letter.originalMissing"));
        }
        if (!Objects.equals(parent.getToUserId(), fromUserId)) {
            throw new BusinessException(appMessages.get("app.error.letter.replyRecipientOnly"));
        }
        long replyTo = parent.getFromUserId();
        if (body.getToUserId() != null && !body.getToUserId().equals(replyTo)) {
            throw new BusinessException(appMessages.get("app.error.letter.replyPeerMismatch"));
        }
        if (replyTo == fromUserId) {
            throw new BusinessException(appMessages.get("app.error.letter.cannotMailSelf"));
        }
        return replyTo;
    }

    /**
     * DIRECT 模式：必须有合法且非本人的 toUserId。
     */
    private Long requireDirectRecipientId(long fromUserId, AppSendLetterInDto body) {
        if (body.getToUserId() == null || body.getToUserId().equals(fromUserId)) {
            throw new BusinessException(appMessages.get("app.error.letter.cannotMailSelf"));
        }
        return body.getToUserId();
    }

    /**
     * 加载并校验收件人：存在、状态正常、双方未互拉黑；无收件人时返回 null。
     */
    private UserDTO loadValidatedRecipient(long fromUserId, Long toUserId) {
        if (toUserId == null) {
            return null;
        }
        UserDTO toUser = userService.findById(toUserId);
        if (toUser == null) {
            throw new BusinessException(appMessages.get("app.error.recipient.notFound"));
        }
        if (userStatus(toUser.getStatus()) != USER_STATUS_NORMAL) {
            throw new BusinessException(appMessages.get("app.error.recipient.statusBad"));
        }
        if (appBlacklistService.areMutuallyBlocked(fromUserId, toUserId)) {
            throw new BusinessException(appMessages.get("app.error.mail.cannotSendToPeer"));
        }
        return toUser;
    }

    /**
     * 查看信件详情：参与方可读；收件人首次打开已送达信时标记已读。
     * <p>前置：viewer 为发/收件人；副作用：可能写 recipientReadAt。
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public MailboxLetterItemVO getLetter(long viewerUserId, long letterId) {
        LetterDomain l = letterService.getById(letterId);
        if (l == null || l.isDelFlag()) {
            throw new BusinessException(appMessages.get("app.error.letter.notFound"));
        }
        boolean participant = Objects.equals(l.getFromUserId(), viewerUserId)
                || (l.getToUserId() != null && Objects.equals(l.getToUserId(), viewerUserId));
        if (!participant) {
            throw new BusinessException(appMessages.get("app.error.letter.noPermissionView"));
        }
        l = markRecipientReadIfNeeded(l, viewerUserId, letterId);
        return toItem(l, viewerUserId, true);
    }

    /**
     * 收件人首次打开已送达信件时标记已读并刷新实体；不满足条件则原样返回。
     */
    private LetterDomain markRecipientReadIfNeeded(LetterDomain letter, long viewerUserId, long letterId) {
        if (!Objects.equals(letter.getToUserId(), viewerUserId)) {
            return letter;
        }
        if (letter.getRecipientReadAt() != null) {
            return letter;
        }
        if (toInt(letter.getStatus()) != LetterBizStatus.DELIVERED.getCode()) {
            return letter;
        }
        boolean marked = letterService.markRecipientRead(letterId, viewerUserId, LocalDateTime.now());
        if (!marked) {
            return letter;
        }
        actionService.recordEvent(
                viewerUserId, BehaviorActionTypes.OPEN_LETTER, BehaviorActionTypes.TARGET_LETTER, letterId, null);
        return letterService.getById(letterId);
    }

    /**
     * 活跃好友列表（含对端公开资料与签名头像）。
     * <p>前置：userId 已登录；无写库副作用。
     */
    @Override
    public List<MailboxFriendItemVO> listFriends(Long userId) {
        List<FriendshipDomain> rows = friendshipService.listActiveFriendshipsForUser(userId);
        List<MailboxFriendItemVO> out = new ArrayList<>();
        for (FriendshipDomain f : rows) {
            long low = f.getUserLow() != null ? f.getUserLow() : 0L;
            long high = f.getUserHigh() != null ? f.getUserHigh() : 0L;
            long peer = low == userId ? high : low;
            UserDTO peerDto = userService.findById(peer);
            if (peerDto == null) {
                continue;
            }
            String avatar = UserAvatarAuditSupport.publicStoredRef(peerDto);
            if (StringUtils.hasText(avatar)) {
                avatar = ossDisplayUrlService.signAvatarForViewer(userId, avatar.trim());
            }
            LocalDateTime connected = f.getUpdatedAt() != null ? f.getUpdatedAt() : f.getCreatedAt();
            out.add(MailboxFriendItemVO.builder()
                    .friendshipId(f.getId())
                    .peerUserId(peer)
                    .peerNickname(peerDto.getNickname())
                    .peerAvatarUrl(avatar)
                    .peerCountryCode(peerDto.getCountryCode())
                    .connectedAt(connected)
                    .build());
        }
        return out;
    }

    /**
     * 信件助手：委托 Spring AI 整理原文建议稿（不落库、不覆盖正文）。
     */
    @Override
    public AppLetterAssistantVO letterAssistant(long userId, AppLetterAssistantInDto body) {
        return letterAssistantService.assist(userId, body);
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

    private List<LetterDomain> loadLettersForUser(Long userId, LocalDateTime since, int limit) {
        return letterService.listMailboxForUser(userId, since, limit);
    }

    private static long peerUserId(LetterDomain l, long viewer) {
        if (l.getToUserId() == null) {
            return 0L;
        }
        if (Objects.equals(l.getFromUserId(), viewer)) {
            return l.getToUserId();
        }
        return l.getFromUserId() != null ? l.getFromUserId() : 0L;
    }

    /**
     * Postal inbox：本人相关且未读；POST_OFFICE 入池仅发件人可见。
     */
    private static boolean includeInPostalInbox(LetterDomain l, long userId) {
        if (l == null || l.isDelFlag()) {
            return false;
        }
        if (l.getToUserId() == null) {
            return Objects.equals(l.getFromUserId(), userId);
        }
        if (!Objects.equals(l.getToUserId(), userId) && !Objects.equals(l.getFromUserId(), userId)) {
            return false;
        }
        return l.getRecipientReadAt() == null;
    }

    private MailboxLetterItemVO toItem(LetterDomain l, long viewer, boolean includeFullContent) {
        long peerId = peerUserId(l, viewer);
        UserDTO peer = peerId > 0 ? userService.findById(peerId) : null;
        boolean fromMe = Objects.equals(l.getFromUserId(), viewer);
        boolean delivering = toInt(l.getStatus()) == LetterBizStatus.DELIVERING.getCode();
        boolean pending = toInt(l.getStatus()) == LetterBizStatus.PENDING.getCode();
        // 运输中对收件人隐藏正文；PENDING 入池发件人可见
        boolean hideBody = !fromMe && delivering;

        String fullContent = l.getContent() != null ? l.getContent() : "";
        String preview = resolvePreviewBody(hideBody, fullContent, 280);
        String contentOut = resolveContentOut(hideBody, includeFullContent, fullContent);
        AppPublicUserVO peerVo = toPublic(peer);
        applyPeerAvatarForViewer(peerVo, peer, viewer);
        LocalDateTime expected = toLocalDateTimeField(l.getExpectedArrivalTime());
        LocalDateTime actual = toLocalDateTimeField(l.getActualArrivalTime());
        Integer mode = l.getMode() != null ? l.getMode() : LetterMode.DIRECT.getCode();
        Integer audit = l.getAuditStatus() != null ? l.getAuditStatus() : LetterAuditStatus.APPROVED.getCode();
        boolean pendingPoolPlaceholder = pending && fromMe && peerId == 0;
        RelationSnapshotVO relation = peerId > 0
                ? appRelationBizService.resolveRelationSnapshot(viewer, peerId)
                : null;
        UserDTO fromUser = l.getFromUserId() != null ? userService.findById(l.getFromUserId()) : null;
        UserDTO toUser = l.getToUserId() != null ? userService.findById(l.getToUserId()) : null;
        LetterContentMeta meta = l.getContentMetaJson();
        String skinId = meta != null ? meta.skinIdOrDefault() : LetterContentMeta.DEFAULT_ID;
        String fontId = meta != null ? meta.fontIdOrDefault() : LetterContentMeta.DEFAULT_ID;
        String fontSizeTier =
                meta != null ? meta.fontSizeTierOrDefault() : LetterContentMeta.FONT_SIZE_LARGE;
        return MailboxLetterItemVO.builder()
                .letterId(l.getId())
                .peer(peerVo)
                .letterType(toInt(l.getLetterType()))
                .sendMode(l.getSendMode() != null ? l.getSendMode() : LetterSendMode.STANDARD_POST.getCode())
                .status(toInt(l.getStatus()))
                .mode(mode)
                .auditStatus(audit)
                .preview(resolveMailboxPreview(pendingPoolPlaceholder, preview))
                .content(contentOut)
                .fromMe(fromMe)
                .sentAt(l.getCreatedAt())
                .updatedAt(l.getUpdatedAt())
                .expectedArrivalTime(expected)
                .actualArrivalTime(actual)
                .contentHidden(hideBody)
                .relationDisplayState(relation != null ? relation.getDisplayState() : null)
                .canAddPenpal(relation != null ? relation.getCanAddPenpal() : false)
                .recipientRead(l.getRecipientReadAt() != null)
                .fromCountryName(resolveCountryName(fromUser))
                .toCountryName(resolveCountryName(toUser))
                .skinId(skinId)
                .fontId(fontId)
                .fontSizeTier(fontSizeTier)
                .build();
    }

    private static String normalizeMetaId(String raw, String defaultValue) {
        if (!StringUtils.hasText(raw)) {
            return defaultValue;
        }
        return raw.trim();
    }

    private String resolveCountryName(UserDTO user) {
        if (user == null || !StringUtils.hasText(user.getCountryCode())) {
            return null;
        }
        CountryDomain country = countryService.findActiveByCode(user.getCountryCode());
        if (country == null) {
            return user.getCountryCode();
        }
        String lang = user.getLanguage();
        if (lang != null && lang.toLowerCase().startsWith("zh")) {
            return StringUtils.hasText(country.getCountryNameZh())
                    ? country.getCountryNameZh()
                    : country.getCountryNameEn();
        }
        return StringUtils.hasText(country.getCountryNameEn())
                ? country.getCountryNameEn()
                : country.getCountryNameZh();
    }

    /**
     * 按隐藏策略生成列表预览；超长截断并加省略号。
     */
    private static String resolvePreviewBody(boolean hideBody, String fullContent, int maxLen) {
        return cn.nine.pros.post.biz.support.TextPreviewSupport.previewOrHidden(hideBody, fullContent, maxLen);
    }

    /**
     * 详情才返回全文；隐藏时返回空串，非详情返回 null。
     */
    private static String resolveContentOut(boolean hideBody, boolean includeFullContent, String fullContent) {
        if (!includeFullContent) {
            return null;
        }
        if (hideBody) {
            return "";
        }
        return fullContent;
    }

    /**
     * POST_OFFICE 入池且无 peer 时，空预览用占位标记便于客户端识别。
     */
    private static String resolveMailboxPreview(boolean pendingPoolPlaceholder, String preview) {
        if (!pendingPoolPlaceholder) {
            return preview;
        }
        return preview.isEmpty() ? "[POST_OFFICE]" : preview;
    }

    /**
     * 为信箱条目 peer VO 填充可展示头像（审核通过引用 + 按查看者签名）。
     */
    private void applyPeerAvatarForViewer(AppPublicUserVO peerVo, UserDTO peer, long viewer) {
        if (peer == null) {
            return;
        }
        String peerAvatarRef = UserAvatarAuditSupport.publicStoredRef(peer);
        if (!StringUtils.hasText(peerAvatarRef)) {
            peerVo.setAvatarUrl(null);
            return;
        }
        peerVo.setAvatarUrl(ossDisplayUrlService.signAvatarRefOrNull(viewer, peerAvatarRef));
    }

    private static LocalDateTime toLocalDateTimeField(Object raw) {
        if (raw == null) {
            return null;
        }
        if (raw instanceof LocalDateTime ldt) {
            return ldt;
        }
        if (raw instanceof java.sql.Timestamp ts) {
            return ts.toLocalDateTime();
        }
        return null;
    }

    private static AppPublicUserVO toPublic(UserDTO dto) {
        if (dto == null) {
            // 未解析到用户：空昵称，避免客户端直出 "unknown"。
            return AppPublicUserVO.builder().id(0L).nickname("").build();
        }
        return AppPublicUserVO.builder()
                .id(dto.getId())
                .nickname(dto.getNickname())
                .gender(dto.getGender())
                .birthYear(dto.getBirthYear())
                .countryCode(dto.getCountryCode())
                .bio(dto.getBio())
                .avatarUrl(UserAvatarAuditSupport.publicStoredRef(dto))
                .isVip(dto.getIsVip())
                .build();
    }

    private static int toInt(Object o) {
        if (o instanceof Number n) {
            return n.intValue();
        }
        if (o instanceof String s) {
            return Integer.parseInt(s);
        }
        return 0;
    }
}
