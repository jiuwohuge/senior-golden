package cn.nine.pros.post.client.api.admin;

import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.out.AdminPostOfficePoolStatusVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Tag(name = "管理后台-邮局冷启动")
@RequestMapping(AppServiceDefine.WEBAPI_PREFIX + "/post-office")
public interface AdminPostOfficeApi {

    @Operation(summary = "池子状态与当前首页主推开关")
    @GetMapping("/pool-status")
    AdminPostOfficePoolStatusVO poolStatus();
}
