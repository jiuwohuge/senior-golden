package cn.nine.pros.post.client.api.admin;

import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.input.app.AppOssGetSignInDto;
import cn.nine.pros.post.client.model.out.OssGetSignBatchResultVO;
import cn.nine.pros.post.client.model.out.OssPutSignResultVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Tag(name = "管理后台-OSS")
@RequestMapping(AppServiceDefine.WEBAPI_PREFIX + "/oss")
public interface AdminOssApi {

    @Operation(summary = "批量获取私有对象 GET 预签名 URL（审核看图；仅校验 key 形态）")
    @PostMapping("/get-sign")
    OssGetSignBatchResultVO getSignBatch(@RequestBody @Valid AppOssGetSignInDto body);

    @Operation(summary = "为指定用户签发 OSS PUT 预签名 URL（管理端代传头像等）")
    @GetMapping("/put-sign")
    OssPutSignResultVO putSign(
            @RequestParam("userId") Long userId,
            @RequestParam("scene") String scene,
            @RequestParam(value = "ext", required = false, defaultValue = "jpg") String ext,
            @RequestParam(value = "contentType", required = false) String contentType);
}
