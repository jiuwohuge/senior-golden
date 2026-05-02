package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.FriendshipDomain;

public interface FriendshipService {

    boolean areActiveFriends(Long userIdA, Long userIdB);

    /**
     * 收件方基于已送达信件建立建联；幂等。
     *
     * @return 新建或已存在的好友关系
     */
    FriendshipDomain ensureActiveFriendship(Long actorUserId, Long letterId);
}
