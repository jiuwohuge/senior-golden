package cn.nine.pros.post.client.api.app;

import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.out.AppPostOfficeHomeVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Tag(name = "App-邮局首页")
@RequestMapping(AppServiceDefine.SERVER_PREFIX + "/post-office")
public interface AppPostOfficeApi {

    @Operation(summary = "邮局首页聚合（问候、额度、关系/在途摘要）")
    @GetMapping("/home")
    AppPostOfficeHomeVO home();
}
