package cn.nine.pros.post.biz.service.biz;

import cn.nine.pros.post.client.model.out.AppBlockedUserItemVO;

import java.util.List;

public interface AppBlacklistService {

    void block(long actorUserId, long blockedUserId, String reason);

    void unblock(long actorUserId, long blockedUserId);

    List<AppBlockedUserItemVO> listBlocks(long actorUserId);

    boolean areMutuallyBlocked(long userIdA, long userIdB);
}
