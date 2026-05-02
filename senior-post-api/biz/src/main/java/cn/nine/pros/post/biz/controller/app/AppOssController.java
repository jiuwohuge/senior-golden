package cn.nine.pros.post.biz.controller.app;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.service.app.AppOssService;
import cn.nine.pros.post.client.api.app.AppOssApi;
import cn.nine.pros.post.client.model.out.OssPutSignResultVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class AppOssController implements AppOssApi {

    private final AppOssService appOssService;

    @Override
    public OssPutSignResultVO putSign(String scene, String ext, String contentType) {
        Long uid = requireUserId();
        return appOssService.signPut(uid, scene, ext, contentType);
    }

    private static Long requireUserId() {
        Long uid = MyRequestContextHolder.userId();
        if (uid == null) {
            throw new BadRequestException("未登录");
        }
        return uid;
    }
}
