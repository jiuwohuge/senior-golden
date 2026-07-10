package cn.nine.pros.post.biz.service.biz.impl;

import cn.nine.commons.basic.exception.unchecked.BusinessException;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.model.domain.LetterDomain;
import cn.nine.pros.post.biz.model.domain.LetterFavoriteDomain;
import cn.nine.pros.post.biz.service.base.ConfigService;
import cn.nine.pros.post.biz.service.base.LetterFavoriteService;
import cn.nine.pros.post.biz.service.base.LetterService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.biz.service.biz.AppLetterFavoriteBizService;
import cn.nine.pros.post.biz.support.TextPreviewSupport;
import cn.nine.pros.post.client.model.db.UserDTO;
import cn.nine.pros.post.client.model.out.AppPublicUserVO;
import cn.nine.pros.post.client.model.out.MailboxLetterItemVO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

@Slf4j
@Service
@RequiredArgsConstructor
public class AppLetterFavoriteBizServiceImpl implements AppLetterFavoriteBizService {

    private static final String KEY_FAVORITE_FREE = "favorite.free_limit";
    private static final String KEY_FAVORITE_VIP = "favorite.vip_limit";
    private static final int DEFAULT_FREE_LIMIT = 20;
    private static final int DEFAULT_VIP_LIMIT = 200;
    private static final int LIST_LIMIT = 200;

    private final LetterFavoriteService letterFavoriteService;
    private final LetterService letterService;
    private final UserService userService;
    private final ConfigService configService;
    private final AppMessages appMessages;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void favorite(long userId, long letterId) {
        LetterDomain letter = letterService.getById(letterId);
        if (letter == null || letter.isDelFlag()) {
            throw new BusinessException(appMessages.get("app.error.favorite.letterNotFound"));
        }
        if (!canAccessLetter(userId, letter)) {
            throw new BusinessException(appMessages.get("app.error.favorite.noPermission"));
        }
        if (letterFavoriteService.isFavorite(userId, letterId)) {
            return;
        }
        assertFavoriteCapacity(userId);
        letterFavoriteService.addFavorite(userId, letterId);
        log.info("letter favorited, userId={}, letterId={}", userId, letterId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void unfavorite(long userId, long letterId) {
        letterFavoriteService.removeFavorite(userId, letterId);
        log.info("letter unfavorited, userId={}, letterId={}", userId, letterId);
    }

    @Override
    public List<MailboxLetterItemVO> listFavorites(long userId) {
        List<MailboxLetterItemVO> out = new ArrayList<>();
        for (LetterFavoriteDomain fav : letterFavoriteService.listForUser(userId, LIST_LIMIT)) {
            if (fav.getLetterId() == null) {
                continue;
            }
            LetterDomain letter = letterService.getById(fav.getLetterId());
            if (letter == null || letter.isDelFlag() || !canAccessLetter(userId, letter)) {
                continue;
            }
            out.add(toItem(letter, userId));
        }
        return out;
    }

    private void assertFavoriteCapacity(long userId) {
        UserDTO user = userService.findById(userId);
        boolean vip = user != null && Boolean.TRUE.equals(user.getIsVip());
        int limit = vip
                ? configService.getInt(KEY_FAVORITE_VIP, DEFAULT_VIP_LIMIT)
                : configService.getInt(KEY_FAVORITE_FREE, DEFAULT_FREE_LIMIT);
        long count = letterFavoriteService.countForUser(userId);
        if (count >= limit) {
            throw new BusinessException(appMessages.get("app.error.favorite.limitReached"));
        }
    }

    private static boolean canAccessLetter(long userId, LetterDomain letter) {
        return Objects.equals(letter.getFromUserId(), userId) || Objects.equals(letter.getToUserId(), userId);
    }

    private MailboxLetterItemVO toItem(LetterDomain letter, long viewerUserId) {
        long peerId = Objects.equals(letter.getFromUserId(), viewerUserId)
                ? letter.getToUserId() != null ? letter.getToUserId() : 0L
                : letter.getFromUserId() != null ? letter.getFromUserId() : 0L;
        UserDTO peer = peerId > 0 ? userService.findById(peerId) : null;
        String content = letter.getContent() != null ? letter.getContent() : "";
        return MailboxLetterItemVO.builder()
                .letterId(letter.getId())
                .peer(peer != null
                        ? AppPublicUserVO.builder().id(peer.getId()).nickname(peer.getNickname()).build()
                        : null)
                .preview(TextPreviewSupport.previewOrHidden(false, content, 280))
                .fromMe(Objects.equals(letter.getFromUserId(), viewerUserId))
                .sentAt(letter.getCreatedAt())
                .updatedAt(letter.getUpdatedAt())
                .build();
    }
}
