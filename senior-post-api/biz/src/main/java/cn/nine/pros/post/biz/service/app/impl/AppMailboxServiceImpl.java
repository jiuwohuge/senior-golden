package cn.nine.pros.post.biz.service.app.impl;

import cn.nine.pros.post.biz.mapper.LetterMapper;
import cn.nine.pros.post.biz.model.domain.FriendshipDomain;
import cn.nine.pros.post.biz.model.domain.LetterDomain;
import cn.nine.pros.post.biz.service.app.AppMailboxService;
import cn.nine.pros.post.biz.service.base.FriendshipService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.client.model.db.UserDTO;
import cn.nine.pros.post.client.model.out.AcceptPostalContactResultVO;
import cn.nine.pros.post.client.model.out.AppPublicUserVO;
import cn.nine.pros.post.client.model.out.LetterSyncResultVO;
import cn.nine.pros.post.client.model.out.MailboxLetterItemVO;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AppMailboxServiceImpl implements AppMailboxService {

    private final LetterMapper letterMapper;
    private final FriendshipService friendshipService;
    private final UserService userService;

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
