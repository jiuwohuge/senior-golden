package cn.nine.pros.post.biz.controller.app;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.service.biz.AppOssService;
import cn.nine.pros.post.client.api.app.AppOssApi;
import cn.nine.pros.post.client.model.input.app.AppOssGetSignInDto;
import cn.nine.pros.post.client.model.out.OssGetSignBatchResultVO;
import cn.nine.pros.post.client.model.out.OssPutSignResultVO;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class AppOssController implements AppOssApi {

    private final AppOssService appOssService;
    private final AppMessages appMessages;

    @Override
    public OssPutSignResultVO putSign(String scene, String ext, String contentType) {
        Long uid = requireUserId();
        return appOssService.signPut(uid, scene, ext, contentType);
    }

    @Override
    public OssGetSignBatchResultVO getSignBatch(@Valid AppOssGetSignInDto body) {
        Long uid = requireUserId();
        return appOssService.signGetBatch(uid, body.getObjectKeys());
    }

    private Long requireUserId() {
        Long uid = MyRequestContextHolder.userId();
        if (uid == null) {
            throw new BadRequestException(appMessages.get("app.error.notLoggedIn"));
        }
        return uid;
    }
}
