package cn.nine.pros.post.biz.service.app.impl;

import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.mapper.LetterMapper;
import cn.nine.pros.post.biz.model.domain.FriendshipDomain;
import cn.nine.pros.post.biz.model.domain.LetterDomain;
import cn.nine.pros.post.biz.service.app.AppBlacklistService;
import cn.nine.pros.post.biz.service.app.AppMailboxService;
import cn.nine.pros.post.biz.service.base.FriendshipService;
import cn.nine.pros.post.biz.service.base.LetterService;
import cn.nine.pros.post.biz.service.base.SensitiveWordService;
import cn.nine.pros.post.biz.service.base.StampAccountService;
import cn.nine.pros.post.biz.service.base.OssDisplayUrlService;
import cn.nine.pros.post.biz.service.base.StampTransactionService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.client.model.db.StampTransactionDTO;
import cn.nine.pros.post.client.model.db.UserDTO;
import cn.nine.pros.post.client.model.input.app.AppSendLetterInDto;
import cn.nine.pros.post.client.model.out.AcceptPostalContactResultVO;
import cn.nine.pros.post.client.model.out.AppPublicUserVO;
import cn.nine.pros.post.client.model.out.LetterSyncResultVO;
import cn.nine.pros.post.client.model.out.MailboxFriendItemVO;
import cn.nine.pros.post.client.model.out.MailboxLetterItemVO;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.concurrent.ThreadLocalRandom;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AppMailboxServiceImpl implements AppMailboxService {

    /** 1=运输中 2=已送达 3=已挂号（预留） */
    private static final int STATUS_DELIVERING = 1;
    private static final int STATUS_DELIVERED = 2;
    private static final int LETTER_TYPE_REGISTERED = 1;
    private static final int LETTER_TYPE_STANDARD = 2;
    private static final int SEND_MODE_STANDARD = 1;
    private static final int SEND_MODE_REGISTERED = 2;
    private static final int SEND_MODE_VIP_DIRECT = 3;
    /** 非 VIP 发送挂号信消耗的邮票数（后续可接配置中心） */
    private static final int REGISTERED_STAMP_COST = 1;
    /** 非 VIP 平邮加速消耗的邮票数 */
    private static final int SPEED_UP_STAMP_COST = 1;
    /** 非 VIP 收件人提前拆信消耗的邮票数 */
    private static final int RECIPIENT_EARLY_OPEN_STAMP_COST = 1;
    private static final int USER_STATUS_NORMAL = 1;

    private final LetterMapper letterMapper;
    private final LetterService letterService;
    private final FriendshipService friendshipService;
    private final UserService userService;
    private final SensitiveWordService sensitiveWordService;
    private final StampAccountService stampAccountService;
    private final StampTransactionService stampTransactionService;
    private final OssDisplayUrlService ossDisplayUrlService;
    private final AppBlacklistService appBlacklistService;

    @Override
    public List<MailboxLetterItemVO> listPostalInbox(Long userId) {
        List<LetterDomain> letters = loadLettersForUser(userId, null, 200);
        List<MailboxLetterItemVO> out = new ArrayList<>();
        for (LetterDomain l : letters) {
            long peer = peerUserId(l, userId);
            if (friendshipService.areActiveFriends(userId, peer)) {
                // 已是笔友时：非「运输中」信件不再进入邮政收件箱（避免历史信占列表）；
                // 「运输中」仍展示，发件人可看到在途，收件人侧继续走 toItem 的内容遮挡逻辑。
                if (toInt(l.getStatus()) != STATUS_DELIVERING) {
                    continue;
                }
            }
            out.add(toItem(l, userId, false));
        }
        return out;
    }

    @Override
    public LetterSyncResultVO sync(Long userId, LocalDateTime since) {
        List<LetterDomain> letters = loadLettersForUser(userId, since, 200);
        List<MailboxLetterItemVO> items = letters.stream()
                .map(l -> toItem(l, userId, false))
                .collect(Collectors.toList());
        return LetterSyncResultVO.builder()
                .letters(items)
                .serverTime(LocalDateTime.now())
                .build();
    }

    @Override
    public List<MailboxLetterItemVO> listArchive(Long userId) {
        return loadLettersForUser(userId, null, 500).stream()
                .map(l -> toItem(l, userId, false))
                .collect(Collectors.toList());
    }

    @Override
    public AcceptPostalContactResultVO acceptPostalContact(Long actorUserId, Long letterId) {
        FriendshipDomain f = friendshipService.ensureActiveFriendship(actorUserId, letterId);
        LetterDomain letter = letterMapper.selectById(letterId);
        long peer = peerUserId(letter, actorUserId);
        return AcceptPostalContactResultVO.builder()
                .friendshipId(f.getId())
                .peerUserId(peer)
                .build();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public MailboxLetterItemVO sendLetter(long fromUserId, AppSendLetterInDto body) {
        Long parentLetterId = body.getParentLetterId();
        long toUserId;
        if (parentLetterId != null) {
            LetterDomain parent = letterMapper.selectById(parentLetterId);
            if (parent == null || parent.isDelFlag()) {
                throw new BadRequestException("原信件不存在");
            }
            if (!Objects.equals(parent.getToUserId(), fromUserId)) {
                throw new BadRequestException("仅收信人可回复该信件");
            }
            long replyTo = parent.getFromUserId();
            if (body.getToUserId() != null && !body.getToUserId().equals(replyTo)) {
                throw new BadRequestException("回复收件人与原信件不一致");
            }
            if (replyTo == fromUserId) {
                throw new BadRequestException("不能给自己寄信");
            }
            toUserId = replyTo;
        } else {
            if (body.getToUserId() == null || body.getToUserId().equals(fromUserId)) {
                throw new BadRequestException("不能给自己寄信");
            }
            toUserId = body.getToUserId();
        }

        String raw = body.getContent();
        if (!StringUtils.hasText(raw)) {
            throw new BadRequestException("信件内容不能为空");
        }
        String content = raw.trim();
        if (content.length() > 20000) {
            throw new BadRequestException("信件过长");
        }
        sensitiveWordService.assertPlainTextAllowed(content);
        int letterType = body.getLetterType();
        if (letterType != LETTER_TYPE_REGISTERED && letterType != LETTER_TYPE_STANDARD) {
            throw new BadRequestException("letterType 须为 1（挂号）或 2（平邮）");
        }

        UserDTO toUser = userService.findById(toUserId);
        if (toUser == null) {
            throw new BadRequestException("收件人不存在");
        }
        if (userStatus(toUser.getStatus()) != USER_STATUS_NORMAL) {
            throw new BadRequestException("收件人状态异常，无法寄信");
        }
        UserDTO sender = userService.findById(fromUserId);
        if (sender == null || userStatus(sender.getStatus()) != USER_STATUS_NORMAL) {
            throw new BadRequestException("发件人状态异常");
        }
        if (appBlacklistService.areMutuallyBlocked(fromUserId, toUserId)) {
            throw new BadRequestException("无法向对方寄信");
        }

        boolean vip = Boolean.TRUE.equals(sender.getIsVip());
        LocalDateTime now = LocalDateTime.now();
        LetterDomain letter = new LetterDomain();
        letter.setFromUserId(fromUserId);
        letter.setToUserId(toUserId);
        letter.setContent(content);
        letter.setIsAccelerated(false);
        letter.setParentLetterId(parentLetterId);

        if (letterType == LETTER_TYPE_STANDARD) {
            letter.setLetterType(LETTER_TYPE_STANDARD);
            letter.setStatus(STATUS_DELIVERING);
            letter.setSendMode(SEND_MODE_STANDARD);
            letter.setExpectedArrivalTime(now.plusMinutes(ThreadLocalRandom.current().nextInt(10, 121)));
            letter.setActualArrivalTime(null);
        } else if (vip) {
            letter.setLetterType(LETTER_TYPE_REGISTERED);
            letter.setStatus(STATUS_DELIVERED);
            letter.setSendMode(SEND_MODE_VIP_DIRECT);
            letter.setExpectedArrivalTime(null);
            letter.setActualArrivalTime(now);
        } else {
            int balance = sender.getStampsBalance() != null ? sender.getStampsBalance() : 0;
            if (balance < REGISTERED_STAMP_COST) {
                throw new BadRequestException("邮票不足，无法发送挂号信");
            }
            letter.setLetterType(LETTER_TYPE_REGISTERED);
            letter.setStatus(STATUS_DELIVERED);
            letter.setSendMode(SEND_MODE_REGISTERED);
            letter.setExpectedArrivalTime(null);
            letter.setActualArrivalTime(now);
        }

        letter.initAudit(fromUserId);
        letterService.save(letter);

        if (letterType == LETTER_TYPE_REGISTERED && !vip) {
            int oldBal = sender.getStampsBalance() != null ? sender.getStampsBalance() : 0;
            int newBal = oldBal - REGISTERED_STAMP_COST;
            boolean patched = stampAccountService.tryDecrementBalance(fromUserId, oldBal,
                    REGISTERED_STAMP_COST, now, fromUserId);
            if (!patched) {
                throw new BadRequestException("邮票扣减失败，请重试");
            }
            StampTransactionDTO tx = new StampTransactionDTO();
            tx.setUserId(fromUserId);
            tx.setChangeAmount(-REGISTERED_STAMP_COST);
            tx.setBalanceAfter(newBal);
            tx.setReason("挂号信消耗");
            tx.setRefId(letter.getId());
            stampTransactionService.upsert(tx);
        }

        LetterDomain saved = letterService.getById(letter.getId());
        return toItem(saved, fromUserId, false);
    }

    @Override
    public MailboxLetterItemVO getLetter(long viewerUserId, long letterId) {
        LetterDomain l = letterMapper.selectById(letterId);
        if (l == null || l.isDelFlag()) {
            throw new BadRequestException("信件不存在");
        }
        if (l.getFromUserId() != viewerUserId && l.getToUserId() != viewerUserId) {
            throw new BadRequestException("无权查看该信件");
        }
        return toItem(l, viewerUserId, true);
    }

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
            String avatar = peerDto.getAvatarUrl();
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

    @Override
    public boolean isFriendshipActive(long viewerUserId, long peerUserId) {
        return friendshipService.areActiveFriends(viewerUserId, peerUserId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public MailboxLetterItemVO earlyOpenLetter(long actorUserId, long letterId) {
        LetterDomain letter = letterMapper.selectById(letterId);
        if (letter == null || letter.isDelFlag()) {
            throw new BadRequestException("信件不存在");
        }
        if (letter.getToUserId() == null || !Objects.equals(letter.getToUserId(), actorUserId)) {
            throw new BadRequestException("仅收件人可提前拆信");
        }
        if (toInt(letter.getLetterType()) != LETTER_TYPE_STANDARD) {
            throw new BadRequestException("仅平邮信件可提前拆信");
        }
        if (toInt(letter.getStatus()) != STATUS_DELIVERING) {
            throw new BadRequestException("当前状态不可提前拆信");
        }
        if (letter.getRecipientEarlyOpenAt() != null) {
            throw new BadRequestException("已提前拆信");
        }
        UserDTO recipient = userService.findById(actorUserId);
        if (recipient == null || userStatus(recipient.getStatus()) != USER_STATUS_NORMAL) {
            throw new BadRequestException("账号状态异常");
        }
        boolean vip = Boolean.TRUE.equals(recipient.getIsVip());
        LocalDateTime now = LocalDateTime.now();
        if (!vip) {
            int oldBal = recipient.getStampsBalance() != null ? recipient.getStampsBalance() : 0;
            if (oldBal < RECIPIENT_EARLY_OPEN_STAMP_COST) {
                throw new BadRequestException("邮票不足，无法提前拆信");
            }
            int newBal = oldBal - RECIPIENT_EARLY_OPEN_STAMP_COST;
            boolean patched = stampAccountService.tryDecrementBalance(actorUserId, oldBal,
                    RECIPIENT_EARLY_OPEN_STAMP_COST, now, actorUserId);
            if (!patched) {
                throw new BadRequestException("邮票扣减失败，请重试");
            }
            StampTransactionDTO tx = new StampTransactionDTO();
            tx.setUserId(actorUserId);
            tx.setChangeAmount(-RECIPIENT_EARLY_OPEN_STAMP_COST);
            tx.setBalanceAfter(newBal);
            tx.setReason("平邮提前拆信消耗");
            tx.setRefId(letterId);
            stampTransactionService.upsert(tx);
        }
        boolean letterPatched = letterService.update(new LambdaUpdateWrapper<LetterDomain>()
                .eq(LetterDomain::getId, letterId)
                .eq(LetterDomain::isDelFlag, false)
                .eq(LetterDomain::getStatus, STATUS_DELIVERING)
                .eq(LetterDomain::getToUserId, actorUserId)
                .isNull(LetterDomain::getRecipientEarlyOpenAt)
                .set(LetterDomain::getRecipientEarlyOpenAt, now)
                // 收件人已付费拆信：对双方列表/归档与「已送达」语义一致，避免仍显示运输中
                .set(LetterDomain::getStatus, STATUS_DELIVERED)
                .set(LetterDomain::getActualArrivalTime, now)
                .set(LetterDomain::getUpdatedAt, now)
                .set(LetterDomain::getUpdatedBy, actorUserId));
        if (!letterPatched) {
            throw new BadRequestException("信件状态已变更，请刷新后重试");
        }
        LetterDomain saved = letterService.getById(letterId);
        return toItem(saved, actorUserId, true);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public MailboxLetterItemVO speedUpLetter(long actorUserId, long letterId) {
        LetterDomain letter = letterMapper.selectById(letterId);
        if (letter == null || letter.isDelFlag()) {
            throw new BadRequestException("信件不存在");
        }
        if (letter.getFromUserId() != actorUserId) {
            throw new BadRequestException("仅发件人可加速平邮");
        }
        if (toInt(letter.getLetterType()) != LETTER_TYPE_STANDARD) {
            throw new BadRequestException("仅平邮信件可加速");
        }
        if (toInt(letter.getStatus()) != STATUS_DELIVERING) {
            throw new BadRequestException("当前状态不可加速");
        }
        if (Boolean.TRUE.equals(letter.getIsAccelerated())) {
            throw new BadRequestException("该信件已加速");
        }

        UserDTO sender = userService.findById(actorUserId);
        if (sender == null || userStatus(sender.getStatus()) != USER_STATUS_NORMAL) {
            throw new BadRequestException("账号状态异常");
        }
        boolean vip = Boolean.TRUE.equals(sender.getIsVip());
        LocalDateTime now = LocalDateTime.now();

        if (!vip) {
            int oldBal = sender.getStampsBalance() != null ? sender.getStampsBalance() : 0;
            if (oldBal < SPEED_UP_STAMP_COST) {
                throw new BadRequestException("邮票不足，无法加速");
            }
            int newBal = oldBal - SPEED_UP_STAMP_COST;
            boolean patched = stampAccountService.tryDecrementBalance(actorUserId, oldBal,
                    SPEED_UP_STAMP_COST, now, actorUserId);
            if (!patched) {
                throw new BadRequestException("邮票扣减失败，请重试");
            }
            StampTransactionDTO tx = new StampTransactionDTO();
            tx.setUserId(actorUserId);
            tx.setChangeAmount(-SPEED_UP_STAMP_COST);
            tx.setBalanceAfter(newBal);
            tx.setReason("平邮加速消耗");
            tx.setRefId(letterId);
            stampTransactionService.upsert(tx);
        }

        boolean letterPatched = letterService.update(new LambdaUpdateWrapper<LetterDomain>()
                .eq(LetterDomain::getId, letterId)
                .eq(LetterDomain::isDelFlag, false)
                .eq(LetterDomain::getStatus, STATUS_DELIVERING)
                .eq(LetterDomain::getFromUserId, actorUserId)
                .set(LetterDomain::getStatus, STATUS_DELIVERED)
                .set(LetterDomain::getIsAccelerated, true)
                .set(LetterDomain::getAcceleratedAt, now)
                .set(LetterDomain::getActualArrivalTime, now)
                .set(LetterDomain::getUpdatedAt, now)
                .set(LetterDomain::getUpdatedBy, actorUserId));
        if (!letterPatched) {
            throw new BadRequestException("信件状态已变更，请刷新后重试");
        }

        LetterDomain saved = letterService.getById(letterId);
        return toItem(saved, actorUserId, false);
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
        LambdaQueryWrapper<LetterDomain> q = new LambdaQueryWrapper<LetterDomain>()
                .eq(LetterDomain::isDelFlag, false)
                .and(w -> w.eq(LetterDomain::getFromUserId, userId).or().eq(LetterDomain::getToUserId, userId));
        if (since != null) {
            q.apply("COALESCE(updated_at, created_at) > {0}", since);
        }
        q.orderByDesc(LetterDomain::getUpdatedAt).last("LIMIT " + limit);
        return letterMapper.selectList(q);
    }

    private static long peerUserId(LetterDomain l, long viewer) {
        if (l.getFromUserId() == viewer) {
            return l.getToUserId();
        }
        return l.getFromUserId();
    }

    private MailboxLetterItemVO toItem(LetterDomain l, long viewer, boolean includeFullContent) {
        long peerId = peerUserId(l, viewer);
        UserDTO peer = userService.findById(peerId);
        boolean fromMe = Objects.equals(l.getFromUserId(), viewer);
        boolean delivering = toInt(l.getStatus()) == STATUS_DELIVERING;
        boolean standard = toInt(l.getLetterType()) == LETTER_TYPE_STANDARD;
        boolean openedEarly = l.getRecipientEarlyOpenAt() != null;
        boolean hideBody = !fromMe && delivering && standard && !openedEarly;

        String fullContent = l.getContent() != null ? l.getContent() : "";
        String preview;
        String contentOut = null;
        if (hideBody) {
            preview = "";
            if (includeFullContent) {
                contentOut = "";
            }
        } else {
            preview = fullContent.length() > 280 ? fullContent.substring(0, 280) + "…" : fullContent;
            if (includeFullContent) {
                contentOut = fullContent;
            }
        }
        AppPublicUserVO peerVo = toPublic(peer);
        if (StringUtils.hasText(peerVo.getAvatarUrl())) {
            peerVo.setAvatarUrl(ossDisplayUrlService.signAvatarForViewer(viewer, peerVo.getAvatarUrl()));
        }
        LocalDateTime expected = toLocalDateTimeField(l.getExpectedArrivalTime());
        LocalDateTime actual = toLocalDateTimeField(l.getActualArrivalTime());
        return MailboxLetterItemVO.builder()
                .letterId(l.getId())
                .peer(peerVo)
                .letterType(toInt(l.getLetterType()))
                .sendMode(l.getSendMode() != null ? l.getSendMode() : 1)
                .status(toInt(l.getStatus()))
                .preview(preview)
                .content(contentOut)
                .fromMe(fromMe)
                .sentAt(l.getCreatedAt())
                .updatedAt(l.getUpdatedAt())
                .expectedArrivalTime(expected)
                .actualArrivalTime(actual)
                .contentHidden(hideBody)
                .build();
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
            return AppPublicUserVO.builder().id(0L).nickname("unknown").build();
        }
        return AppPublicUserVO.builder()
                .id(dto.getId())
                .email(dto.getEmail())
                .nickname(dto.getNickname())
                .birthYear(dto.getBirthYear())
                .countryCode(dto.getCountryCode())
                .bio(dto.getBio())
                .avatarUrl(dto.getAvatarUrl())
                .stampsBalance(dto.getStampsBalance())
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
