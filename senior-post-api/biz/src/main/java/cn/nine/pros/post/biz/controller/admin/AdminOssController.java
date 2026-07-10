package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.model.domain.UserDomain;
import cn.nine.pros.post.biz.service.biz.AppOssService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.client.api.admin.AdminOssApi;
import cn.nine.pros.post.client.model.input.app.AppOssGetSignInDto;
import cn.nine.pros.post.client.model.out.OssGetSignBatchResultVO;
import cn.nine.pros.post.client.model.out.OssPutSignResultVO;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class AdminOssController implements AdminOssApi {

    private final AppOssService appOssService;
    private final UserService userService;
    private final AppMessages appMessages;

    @Override
    public OssGetSignBatchResultVO getSignBatch(@Valid AppOssGetSignInDto body) {
        return appOssService.signGetBatchStaff(body.getObjectKeys());
    }

    @Override
    public OssPutSignResultVO putSign(Long userId, String scene, String ext, String contentType) {
        assertTargetUserExists(userId);
        return appOssService.signPut(userId, scene, ext, contentType);
    }

    private void assertTargetUserExists(Long userId) {
        if (userId == null || userId <= 0) {
            throw new BadRequestException(appMessages.get("admin.error.user.badId"));
        }
        UserDomain user = userService.getById(userId);
        if (user == null || user.isDelFlag()) {
            throw new BadRequestException(appMessages.get("admin.error.user.notFound"));
        }
    }
}
