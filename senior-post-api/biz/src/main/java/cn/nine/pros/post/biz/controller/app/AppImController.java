package cn.nine.pros.post.biz.controller.app;

import cn.nine.pros.post.biz.service.app.AppImService;
import cn.nine.pros.post.client.api.app.AppImApi;
import cn.nine.pros.post.client.model.out.AppImUserSigVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class AppImController implements AppImApi {

    private final AppImService appImService;

    @Override
    public AppImUserSigVO userSig() {
        return appImService.currentUserSig();
    }

    @Override
    public void compensateChatPeer(Long peerUserId) {
        appImService.compensateChatPeer(peerUserId);
    }
}
