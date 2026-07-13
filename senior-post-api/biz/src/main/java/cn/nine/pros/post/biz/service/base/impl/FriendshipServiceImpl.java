package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.mapper.FriendshipMapper;
import cn.nine.pros.post.biz.model.domain.FriendshipDomain;
import cn.nine.pros.post.biz.model.domain.LetterDomain;
import cn.nine.pros.post.biz.service.base.FriendshipService;
import cn.nine.pros.post.biz.service.base.LetterService;
import cn.nine.pros.post.biz.support.PageQueryNormalize;
import cn.nine.pros.post.client.common.enums.LetterBizStatus;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class FriendshipServiceImpl implements FriendshipService {

    private final FriendshipMapper friendshipMapper;
    private final LetterService letterService;
    private final AppMessages appMessages;

    @Override
    public boolean areActiveFriends(Long userIdA, Long userIdB) {
        if (userIdA == null || userIdB == null) {
            return false;
        }
        if (userIdA.equals(userIdB)) {
            return true;
        }
        long low = Math.min(userIdA, userIdB);
        long high = Math.max(userIdA, userIdB);
        return friendshipMapper.selectCount(new LambdaQueryWrapper<FriendshipDomain>()
                .eq(FriendshipDomain::getUserLow, low)
                .eq(FriendshipDomain::getUserHigh, high)
                .eq(FriendshipDomain::getStatus, 1)
                .eq(FriendshipDomain::isDelFlag, false)) > 0;
    }

    @Override
    public List<FriendshipDomain> listActiveFriendshipsForUser(long userId) {
        return friendshipMapper.selectList(new LambdaQueryWrapper<FriendshipDomain>()
                .eq(FriendshipDomain::getStatus, 1)
                .eq(FriendshipDomain::isDelFlag, false)
                .and(w -> w.eq(FriendshipDomain::getUserLow, userId).or().eq(FriendshipDomain::getUserHigh, userId))
                .orderByDesc(FriendshipDomain::getUpdatedAt));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public FriendshipDomain ensureActiveFriendship(Long actorUserId, Long letterId) {
        LetterDomain letter = letterService.getById(letterId);
        if (letter == null || Boolean.TRUE.equals(letter.isDelFlag())) {
            throw new BadRequestException(appMessages.get("app.error.friendship.letterNotFound"));
        }
        if (!actorUserId.equals(letter.getToUserId())) {
            throw new BadRequestException(appMessages.get("app.error.friendship.recipientOnly"));
        }
        int st = statusToInt(letter.getStatus());
        if (st != LetterBizStatus.DELIVERED.getCode()) {
            throw new BadRequestException(appMessages.get("app.error.friendship.letterNotDelivered"));
        }
        long low = Math.min(letter.getFromUserId(), letter.getToUserId());
        long high = Math.max(letter.getFromUserId(), letter.getToUserId());
        FriendshipDomain existing = friendshipMapper.selectOne(new LambdaQueryWrapper<FriendshipDomain>()
                .eq(FriendshipDomain::getUserLow, low)
                .eq(FriendshipDomain::getUserHigh, high)
                .eq(FriendshipDomain::isDelFlag, false));
        if (existing != null) {
            return ensureExistingFriendshipActive(existing, actorUserId, letterId);
        }
        FriendshipDomain f = new FriendshipDomain();
        f.initAudit(actorUserId);
        f.setUserLow(low);
        f.setUserHigh(high);
        f.setStatus(1);
        f.setSourceLetterId(letterId);
        f.setDelFlag(false);
        friendshipMapper.insert(f);
        return f;
    }

    private FriendshipDomain ensureExistingFriendshipActive(
            FriendshipDomain existing, Long actorUserId, Long letterId) {
        if (existing.getStatus() != null && existing.getStatus() == 1) {
            return existing;
        }
        existing.setStatus(1);
        existing.setSourceLetterId(letterId);
        existing.updateAudit(actorUserId);
        friendshipMapper.updateById(existing);
        return existing;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deactivateAllFriendshipsForUser(long userId) {
        List<FriendshipDomain> rows = friendshipMapper.selectList(new LambdaQueryWrapper<FriendshipDomain>()
                .eq(FriendshipDomain::getStatus, 1)
                .eq(FriendshipDomain::isDelFlag, false)
                .and(w -> w.eq(FriendshipDomain::getUserLow, userId).or().eq(FriendshipDomain::getUserHigh, userId)));
        for (FriendshipDomain f : rows) {
            f.setStatus(0);
            f.updateAudit(userId);
            friendshipMapper.updateById(f);
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public FriendshipDomain createPenpalFromRequest(
            long actorUserId, long requesterId, long targetId, Long sourceLetterId) {
        long low = Math.min(requesterId, targetId);
        long high = Math.max(requesterId, targetId);
        FriendshipDomain existing = friendshipMapper.selectOne(new LambdaQueryWrapper<FriendshipDomain>()
                .eq(FriendshipDomain::getUserLow, low)
                .eq(FriendshipDomain::getUserHigh, high)
                .eq(FriendshipDomain::isDelFlag, false));
        if (existing != null) {
            return ensureExistingFriendshipActive(existing, actorUserId, sourceLetterId);
        }
        FriendshipDomain f = new FriendshipDomain();
        f.initAudit(actorUserId);
        f.setUserLow(low);
        f.setUserHigh(high);
        f.setStatus(1);
        f.setSourceLetterId(sourceLetterId);
        f.setDelFlag(false);
        friendshipMapper.insert(f);
        return f;
    }

    @Override
    public FriendshipDomain getById(Long id) {
        if (id == null) {
            return null;
        }
        return friendshipMapper.selectById(id);
    }

    @Override
    public Page<FriendshipDomain> pageForAdmin(
            cn.nine.commons.data.page.PageQuery pageQuery,
            Long userId, Long peerId,
            LocalDateTime createdFrom, LocalDateTime createdTo) {
        LambdaQueryWrapper<FriendshipDomain> qw = new LambdaQueryWrapper<FriendshipDomain>()
                .eq(FriendshipDomain::isDelFlag, false)
                .eq(FriendshipDomain::getStatus, 1)
                .orderByDesc(FriendshipDomain::getCreatedAt);
        if (userId != null && peerId != null) {
            long low = Math.min(userId, peerId);
            long high = Math.max(userId, peerId);
            qw.eq(FriendshipDomain::getUserLow, low).eq(FriendshipDomain::getUserHigh, high);
        } else if (userId != null) {
            qw.and(w -> w.eq(FriendshipDomain::getUserLow, userId)
                    .or()
                    .eq(FriendshipDomain::getUserHigh, userId));
        } else if (peerId != null) {
            qw.and(w -> w.eq(FriendshipDomain::getUserLow, peerId)
                    .or()
                    .eq(FriendshipDomain::getUserHigh, peerId));
        }
        if (createdFrom != null) {
            qw.ge(FriendshipDomain::getCreatedAt, createdFrom);
        }
        if (createdTo != null) {
            qw.le(FriendshipDomain::getCreatedAt, createdTo);
        }
        return friendshipMapper.selectPage(
                PageQueryNormalize.mpPage(pageQuery, PageQueryNormalize.ADMIN_MAX_SIZE), qw);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean deactivateById(long id, Long actorUserId) {
        FriendshipDomain f = friendshipMapper.selectById(id);
        if (f == null || Boolean.TRUE.equals(f.isDelFlag())) {
            return false;
        }
        if (f.getStatus() != null && f.getStatus() == 0) {
            return true;
        }
        f.setStatus(0);
        f.updateAudit(actorUserId);
        return friendshipMapper.updateById(f) > 0;
    }

    @Override
    public long countActive() {
        return friendshipMapper.selectCount(new LambdaQueryWrapper<FriendshipDomain>()
                .eq(FriendshipDomain::isDelFlag, false)
                .eq(FriendshipDomain::getStatus, 1));
    }

    private static int statusToInt(Object status) {
        if (status instanceof Number n) {
            return n.intValue();
        }
        if (status instanceof String s) {
            return Integer.parseInt(s);
        }
        return 0;
    }
}
