package cn.nine.pros.post.biz.service.biz.impl;

import cn.nine.pros.post.biz.model.domain.UserPreferenceDomain;
import cn.nine.pros.post.biz.service.base.FriendshipService;
import cn.nine.pros.post.biz.service.base.LetterService;
import cn.nine.pros.post.biz.service.base.TimeLetterService;
import cn.nine.pros.post.biz.service.base.UserPreferenceService;
import cn.nine.pros.post.biz.service.biz.AppProfileBizService;
import cn.nine.pros.post.client.model.input.app.UserPreferencesPatchInDto;
import cn.nine.pros.post.client.model.out.ProfileOverviewVO;
import cn.nine.pros.post.client.model.out.UserPreferencesVO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AppProfileBizServiceImpl implements AppProfileBizService {

    private final FriendshipService friendshipService;
    private final LetterService letterService;
    private final TimeLetterService timeLetterService;
    private final UserPreferenceService userPreferenceService;

    @Override
    public ProfileOverviewVO overview(long userId) {
        int penpals = friendshipService.listActiveFriendshipsForUser(userId).size();
        int letters = (int) letterService.countDeliveredParticipationForUser(userId);
        int timeLetters = (int) timeLetterService.countOwnedNonDraft(userId);
        return ProfileOverviewVO.builder()
                .penpalCount(penpals)
                .letterCount(letters)
                .timeLetterCount(timeLetters)
                .build();
    }

    @Override
    public UserPreferencesVO preferences(long userId) {
        return toVo(userPreferenceService.findOrCreateForUser(userId));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public UserPreferencesVO patchPreferences(long userId, UserPreferencesPatchInDto body) {
        UserPreferenceDomain row = userPreferenceService.findOrCreateForUser(userId);
        if (body != null && body.getPrivacy() != null) {
            row = userPreferenceService.mergePrivacy(userId, body.getPrivacy());
        }
        if (body != null && body.getNotifications() != null) {
            row = userPreferenceService.mergeNotifications(userId, body.getNotifications());
        }
        return toVo(row);
    }

    private static UserPreferencesVO toVo(UserPreferenceDomain row) {
        if (row == null) {
            return UserPreferencesVO.builder().build();
        }
        return UserPreferencesVO.builder()
                .privacy(row.getPrivacyJson())
                .notifications(row.getNotificationsJson())
                .build();
    }
}
