package cn.nine.pros.post.client.api.admin;

import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.input.app.AppOssGetSignInDto;
import cn.nine.pros.post.client.model.out.OssGetSignBatchResultVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

@Tag(name = "管理后台-OSS")
@RequestMapping(AppServiceDefine.WEBAPI_PREFIX + "/oss")
public interface AdminOssApi {

    @Operation(summary = "批量获取私有对象 GET 预签名 URL（审核看图；仅校验 key 形态）")
    @PostMapping("/get-sign")
    OssGetSignBatchResultVO getSignBatch(@RequestBody @Valid AppOssGetSignInDto body);
}
