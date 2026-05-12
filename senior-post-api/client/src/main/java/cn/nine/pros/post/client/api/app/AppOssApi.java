package cn.nine.pros.post.client.api.app;

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

@Tag(name = "App-OSS")
@RequestMapping(AppServiceDefine.SERVER_PREFIX + "/oss")
public interface AppOssApi {

    @Operation(summary = "获取对象直传 PUT 预签名 URL（客户端 PUT 二进制至 OSS）")
    @GetMapping("/put-sign")
    OssPutSignResultVO putSign(
            @RequestParam("scene") String scene,
            @RequestParam(value = "ext", required = false, defaultValue = "jpg") String ext,
            @RequestParam(value = "contentType", required = false) String contentType);

    @Operation(summary = "批量获取私有对象 GET 预签名 URL（用于展示图片；objectKey 须符合上传路径规则）")
    @PostMapping("/get-sign")
    OssGetSignBatchResultVO getSignBatch(@RequestBody @Valid AppOssGetSignInDto body);
}
