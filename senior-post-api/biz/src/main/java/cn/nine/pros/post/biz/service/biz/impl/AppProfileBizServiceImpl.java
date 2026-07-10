package cn.nine.pros.post.biz.service.biz.impl;

import cn.nine.pros.post.biz.service.base.FriendshipService;
import cn.nine.pros.post.biz.service.base.LetterService;
import cn.nine.pros.post.biz.service.base.TimeLetterService;
import cn.nine.pros.post.biz.service.biz.AppProfileBizService;
import cn.nine.pros.post.client.model.out.ProfileOverviewVO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AppProfileBizServiceImpl implements AppProfileBizService {

    private final FriendshipService friendshipService;
    private final LetterService letterService;
    private final TimeLetterService timeLetterService;

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
}
