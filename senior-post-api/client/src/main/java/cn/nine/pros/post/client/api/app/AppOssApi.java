package cn.nine.pros.post.client.api.app;

import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.out.OssPutSignResultVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Tag(name = "App-OSS")
public interface AppOssApi {

    @Operation(summary = "获取对象直传 PUT 预签名 URL（客户端 PUT 二进制至 OSS）")
    @GetMapping(AppServiceDefine.SERVER_PREFIX + "/oss/put-sign")
    OssPutSignResultVO putSign(
            @RequestParam("scene") String scene,
            @RequestParam(value = "ext", required = false, defaultValue = "jpg") String ext,
            @RequestParam(value = "contentType", required = false) String contentType);
}
