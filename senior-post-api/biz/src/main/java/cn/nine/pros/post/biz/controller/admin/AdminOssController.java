package cn.nine.pros.post.biz.controller.admin;

import cn.nine.pros.post.biz.service.app.AppOssService;
import cn.nine.pros.post.client.api.admin.AdminOssApi;
import cn.nine.pros.post.client.model.input.app.AppOssGetSignInDto;
import cn.nine.pros.post.client.model.out.OssGetSignBatchResultVO;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class AdminOssController implements AdminOssApi {

    private final AppOssService appOssService;

    @Override
    public OssGetSignBatchResultVO getSignBatch(@Valid AppOssGetSignInDto body) {
        return appOssService.signGetBatchStaff(body.getObjectKeys());
    }
}
