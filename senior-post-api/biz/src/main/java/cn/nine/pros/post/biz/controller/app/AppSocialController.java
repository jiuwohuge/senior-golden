package cn.nine.pros.post.biz.controller.app;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.service.app.AppBlacklistService;
import cn.nine.pros.post.client.api.app.AppSocialApi;
import cn.nine.pros.post.client.model.input.app.AppBlacklistBlockInDto;
import cn.nine.pros.post.client.model.out.AppBlockedUserItemVO;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class AppSocialController implements AppSocialApi {

    private final AppBlacklistService appBlacklistService;

    @Override
    public void block(@Valid AppBlacklistBlockInDto body) {
        long uid = requireUserId();
        appBlacklistService.block(uid, body.getBlockedUserId(), body.getReason());
    }

    @Override
    public void unblock(Long blockedUserId) {
        long uid = requireUserId();
        appBlacklistService.unblock(uid, blockedUserId);
    }

    @Override
    public List<AppBlockedUserItemVO> listBlocks() {
        long uid = requireUserId();
        return appBlacklistService.listBlocks(uid);
    }

    private static long requireUserId() {
        Long uid = MyRequestContextHolder.userId();
        if (uid == null) {
            throw new BadRequestException("未登录");
        }
        return uid;
    }
}
