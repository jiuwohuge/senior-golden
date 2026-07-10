package cn.nine.pros.post.biz.controller.app;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.service.biz.AppRelationBizService;
import cn.nine.pros.post.client.api.app.AppRelationApi;
import cn.nine.pros.post.client.model.input.app.CreatePenpalRequestInDto;
import cn.nine.pros.post.client.model.out.PenpalRequestResultVO;
import cn.nine.pros.post.client.model.out.RelationSnapshotVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class AppRelationController implements AppRelationApi {

    private final AppRelationBizService appRelationBizService;
    private final AppMessages appMessages;

    @Override
    public RelationSnapshotVO relationWith(Long userId) {
        return appRelationBizService.resolveRelationSnapshot(requireUserId(), userId);
    }

    @Override
    public PenpalRequestResultVO createPenpalRequest(CreatePenpalRequestInDto body) {
        return appRelationBizService.createPenpalRequest(requireUserId(), body);
    }

    @Override
    public PenpalRequestResultVO acceptPenpalRequest(Long requestId) {
        return appRelationBizService.acceptPenpalRequest(requireUserId(), requestId);
    }

    @Override
    public PenpalRequestResultVO ignorePenpalRequest(Long requestId) {
        return appRelationBizService.ignorePenpalRequest(requireUserId(), requestId);
    }

    private Long requireUserId() {
        Long uid = MyRequestContextHolder.userId();
        if (uid == null) {
            throw new BadRequestException(appMessages.get("app.error.notLoggedIn"));
        }
        return uid;
    }
}
