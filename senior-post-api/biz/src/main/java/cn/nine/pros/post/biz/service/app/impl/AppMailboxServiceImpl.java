package cn.nine.pros.post.biz.service.app.impl;

import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.mapper.LetterMapper;
import cn.nine.pros.post.biz.model.domain.FriendshipDomain;
import cn.nine.pros.post.biz.model.domain.LetterDomain;
import cn.nine.pros.post.biz.model.domain.UserDomain;
import cn.nine.pros.post.biz.service.app.AppMailboxService;
import cn.nine.pros.post.biz.service.base.FriendshipService;
import cn.nine.pros.post.biz.service.base.LetterService;
import cn.nine.pros.post.biz.service.base.StampTransactionService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.client.model.db.StampTransactionDTO;
import cn.nine.pros.post.client.model.db.UserDTO;
import cn.nine.pros.post.client.model.input.app.AppSendLetterInDto;
import cn.nine.pros.post.client.model.out.AcceptPostalContactResultVO;
import cn.nine.pros.post.client.model.out.AppPublicUserVO;
import cn.nine.pros.post.client.model.out.LetterSyncResultVO;
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
    private static final int USER_STATUS_NORMAL = 1;

    private final LetterMapper letterMapper;
    private final LetterService letterService;
    private final FriendshipService friendshipService;
    private final UserService userService;
    private final StampTransactionService stampTransactionService;

    @Override
    public List<MailboxLetterItemVO> listPostalInbox(Long userId) {
        List<LetterDomain> letters = loadLettersForUser(userId, null, 200);
        List<MailboxLetterItemVO> out = new ArrayList<>();
        for (LetterDomain l : letters) {
            long peer = peerUserId(l, userId);
            if (friendshipService.areActiveFriends(userId, peer)) {
                continue;
            }
            out.add(toItem(l, userId));
        }
        return out;
    }

    @Override
    public LetterSyncResultVO sync(Long userId, LocalDateTime since) {
        List<LetterDomain> letters = loadLettersForUser(userId, since, 200);
        List<MailboxLetterItemVO> items = letters.stream()
                .map(l -> toItem(l, userId))
                .collect(Collectors.toList());
        return LetterSyncResultVO.builder()
                .letters(items)
                .serverTime(LocalDateTime.now())
                .build();
    }

    @Override
    public List<MailboxLetterItemVO> listArchive(Long userId) {
        return loadLettersForUser(userId, null, 500).stream()
                .map(l -> toItem(l, userId))
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
        if (body.getToUserId() == null || body.getToUserId().equals(fromUserId)) {
            throw new BadRequestException("不能给自己寄信");
        }
        String raw = body.getContent();
        if (!StringUtils.hasText(raw)) {
            throw new BadRequestException("信件内容不能为空");
        }
        String content = raw.trim();
        if (content.length() > 20000) {
            throw new BadRequestException("信件过长");
        }
        int letterType = body.getLetterType();
        if (letterType != LETTER_TYPE_REGISTERED && letterType != LETTER_TYPE_STANDARD) {
            throw new BadRequestException("letterType 须为 1（挂号）或 2（平邮）");
        }

        UserDTO toUser = userService.findById(body.getToUserId());
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

        boolean vip = Boolean.TRUE.equals(sender.getIsVip());
        LocalDateTime now = LocalDateTime.now();
        LetterDomain letter = new LetterDomain();
        letter.setFromUserId(fromUserId);
        letter.setToUserId(body.getToUserId());
        letter.setContent(content);
        letter.setIsAccelerated(false);
        letter.setParentLetterId(null);

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
            boolean patched = userService.update(new LambdaUpdateWrapper<UserDomain>()
                    .eq(UserDomain::getId, fromUserId)
                    .eq(UserDomain::isDelFlag, false)
                    .eq(UserDomain::getStampsBalance, oldBal)
                    .set(UserDomain::getStampsBalance, newBal)
                    .set(UserDomain::getUpdatedAt, now)
                    .set(UserDomain::getUpdatedBy, fromUserId));
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
        return toItem(saved, fromUserId);
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
            q.gt(LetterDomain::getUpdatedAt, since);
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

    private MailboxLetterItemVO toItem(LetterDomain l, long viewer) {
        long peerId = peerUserId(l, viewer);
        UserDTO peer = userService.findById(peerId);
        String content = l.getContent() != null ? l.getContent() : "";
        String preview = content.length() > 280 ? content.substring(0, 280) + "…" : content;
        return MailboxLetterItemVO.builder()
                .letterId(l.getId())
                .peer(toPublic(peer))
                .letterType(toInt(l.getLetterType()))
                .sendMode(l.getSendMode() != null ? l.getSendMode() : 1)
                .status(toInt(l.getStatus()))
                .preview(preview)
                .fromMe(l.getFromUserId() == viewer)
                .sentAt(l.getCreatedAt())
                .updatedAt(l.getUpdatedAt())
                .build();
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
