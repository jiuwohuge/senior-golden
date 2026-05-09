package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.FriendshipDomain;

import java.util.List;

public interface FriendshipService {

    boolean areActiveFriends(Long userIdA, Long userIdB);

    /**
     * 当前用户的活跃好友关系（{@code bu_friendship} status=1），按更新时间倒序。
     */
    List<FriendshipDomain> listActiveFriendshipsForUser(long userId);

    /**
     * 收件方基于已送达信件建立建联；幂等。
     *
     * @return 新建或已存在的好友关系
     */
    FriendshipDomain ensureActiveFriendship(Long actorUserId, Long letterId);

    /**
     * 账号正式注销（冷静期结束）时：将涉及该用户的本地好友关系置为失效，并尽力同步删除腾讯 IM 好友。
     */
    void deactivateAllFriendshipsForUser(long userId);
}
