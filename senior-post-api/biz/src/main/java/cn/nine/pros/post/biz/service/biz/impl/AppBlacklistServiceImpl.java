package cn.nine.pros.post.biz.service.biz.impl;

import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.model.domain.UserBlacklistDomain;
import cn.nine.pros.post.biz.service.biz.AppBlacklistService;
import cn.nine.pros.post.biz.service.base.OssDisplayUrlService;
import cn.nine.pros.post.biz.service.biz.support.UserAvatarAuditSupport;
import cn.nine.pros.post.biz.service.base.UserBlacklistService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.client.model.db.UserDTO;
import cn.nine.pros.post.client.model.out.AppBlockedUserItemVO;
import cn.nine.pros.post.client.model.out.AppPublicUserVO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AppBlacklistServiceImpl implements AppBlacklistService {

        private final UserService userService;
    private final OssDisplayUrlService ossDisplayUrlService;
    private final AppMessages appMessages;
    private final UserBlacklistService userBlacklistService;

    @Override
    public void block(long actorUserId, long blockedUserId, String reason) {
        if (actorUserId == blockedUserId) {
            throw new BadRequestException(appMessages.get("app.error.block.cannotBlockSelf"));
        }
        UserDTO peer = userService.findById(blockedUserId);
        if (peer == null) {
            throw new BadRequestException(appMessages.get("app.error.block.userNotFound"));
        }
        UserBlacklistDomain row = userBlacklistService.findByPair(actorUserId, blockedUserId);
        LocalDateTime now = LocalDateTime.now();
        String r = StringUtils.hasText(reason) ? reason.trim() : null;
        if (row == null) {
            UserBlacklistDomain d = new UserBlacklistDomain();
            d.setUserId(actorUserId);
            d.setBlockedUserId(blockedUserId);
            d.setReason(r);
            d.initAudit(actorUserId);
            userBlacklistService.save(d);
            return;
        }
        if (!row.isDelFlag()) {
            throw new BadRequestException(appMessages.get("app.error.block.alreadyBlocked"));
        }
        row.setDelFlag(false);
        row.setReason(r);
        row.setUpdatedAt(now);
        row.setUpdatedBy(actorUserId);
        userBlacklistService.restore(row);
    }

    @Override
    public void unblock(long actorUserId, long blockedUserId) {
        boolean ok = userBlacklistService.softUnblock(actorUserId, blockedUserId);
        if (!ok) {
            throw new BadRequestException(appMessages.get("app.error.block.recordNotFound"));
        }
    }

    @Override
    public List<AppBlockedUserItemVO> listBlocks(long actorUserId) {
        List<UserBlacklistDomain> rows = userBlacklistService.listActiveByUserId(actorUserId);
        List<AppBlockedUserItemVO> out = new ArrayList<>();
        for (UserBlacklistDomain row : rows) {
            UserDTO u = userService.findById(row.getBlockedUserId());
            if (u == null) {
                continue;
            }
            AppPublicUserVO peer = toPublic(u);
            String avatarRef = UserAvatarAuditSupport.publicStoredRef(u);
            if (StringUtils.hasText(avatarRef)) {
                peer.setAvatarUrl(ossDisplayUrlService.signAvatarForViewer(actorUserId, avatarRef));
            } else {
                peer.setAvatarUrl(null);
            }
            out.add(AppBlockedUserItemVO.builder()
                    .blockedUserId(row.getBlockedUserId())
                    .peer(peer)
                    .blockedAt(toLdt(row.getCreatedAt()))
                    .build());
        }
        return out;
    }

    @Override
    public boolean areMutuallyBlocked(long userIdA, long userIdB) {
        if (userIdA == userIdB) {
            return false;
        }
        return activeBlock(userIdA, userIdB) || activeBlock(userIdB, userIdA);
    }

    private boolean activeBlock(long blocker, long blocked) {
        return userBlacklistService.existsActiveBlock(blocker, blocked);
    }

    private static LocalDateTime toLdt(Object raw) {
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

    private static AppPublicUserVO toPublic(UserDTO u) {
        if (u == null) {
            return AppPublicUserVO.builder().id(0L).nickname("").build();
        }
        String cc = u.getCountryCode() == null ? "" : u.getCountryCode();
        return AppPublicUserVO.builder()
                .id(u.getId())
                .nickname(u.getNickname() == null ? "User" : u.getNickname())
                .gender(u.getGender())
                .birthYear(u.getBirthYear())
                .countryCode(cc)
                .bio(u.getBio())
                .avatarUrl(UserAvatarAuditSupport.publicStoredRef(u))
                .isVip(u.getIsVip())
                .build();
    }
}