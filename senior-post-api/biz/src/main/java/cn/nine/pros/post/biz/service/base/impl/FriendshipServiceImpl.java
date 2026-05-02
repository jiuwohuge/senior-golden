package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.mapper.FriendshipMapper;
import cn.nine.pros.post.biz.mapper.LetterMapper;
import cn.nine.pros.post.biz.model.domain.FriendshipDomain;
import cn.nine.pros.post.biz.model.domain.LetterDomain;
import cn.nine.pros.post.biz.service.base.FriendshipService;
import cn.nine.pros.post.client.common.enums.LetterBizStatus;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class FriendshipServiceImpl implements FriendshipService {

    private final FriendshipMapper friendshipMapper;
    private final LetterMapper letterMapper;
    private final cn.nine.pros.post.biz.integration.tencent.TencentImFriendshipNotifier tencentImFriendshipNotifier;

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
    @Transactional(rollbackFor = Exception.class)
    public FriendshipDomain ensureActiveFriendship(Long actorUserId, Long letterId) {
        LetterDomain letter = letterMapper.selectById(letterId);
        if (letter == null || Boolean.TRUE.equals(letter.isDelFlag())) {
            throw new BadRequestException("信件不存在");
        }
        if (!actorUserId.equals(letter.getToUserId())) {
            throw new BadRequestException("仅收件人可建立建联");
        }
        int st = statusToInt(letter.getStatus());
        if (st != LetterBizStatus.DELIVERED.getCode()) {
            throw new BadRequestException("信件未送达，无法建联");
        }
        long low = Math.min(letter.getFromUserId(), letter.getToUserId());
        long high = Math.max(letter.getFromUserId(), letter.getToUserId());
        FriendshipDomain existing = friendshipMapper.selectOne(new LambdaQueryWrapper<FriendshipDomain>()
                .eq(FriendshipDomain::getUserLow, low)
                .eq(FriendshipDomain::getUserHigh, high)
                .eq(FriendshipDomain::isDelFlag, false));
        if (existing != null) {
            if (existing.getStatus() != null && existing.getStatus() == 1) {
                tencentImFriendshipNotifier.afterFriendshipActive(low, high);
                return existing;
            }
            existing.setStatus(1);
            existing.setSourceLetterId(letterId);
            existing.updateAudit(actorUserId);
            friendshipMapper.updateById(existing);
            tencentImFriendshipNotifier.afterFriendshipActive(low, high);
            return existing;
        }
        FriendshipDomain f = new FriendshipDomain();
        f.initAudit(actorUserId);
        f.setUserLow(low);
        f.setUserHigh(high);
        f.setStatus(1);
        f.setSourceLetterId(letterId);
        f.setDelFlag(false);
        friendshipMapper.insert(f);
        tencentImFriendshipNotifier.afterFriendshipActive(low, high);
        return f;
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
