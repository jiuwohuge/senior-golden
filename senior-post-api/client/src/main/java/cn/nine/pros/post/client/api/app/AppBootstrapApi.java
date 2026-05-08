package cn.nine.pros.post.client.api.app;

import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.out.AppBootstrapVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Tag(name = "App-启动配置")
public interface AppBootstrapApi {

    @Operation(summary = "启动配置（注册门槛、国家列表、可选兴趣标签选项）")
    @GetMapping(AppServiceDefine.SERVER_PREFIX + "/bootstrap/init")
    AppBootstrapVO init(@RequestParam(value = "lang", required = false) String lang);
}
