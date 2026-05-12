package cn.nine.pros.post.client.api.app;

import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.out.AppBootstrapVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Tag(name = "App-启动配置")
@RequestMapping(AppServiceDefine.SERVER_PREFIX + "/bootstrap")
public interface AppBootstrapApi {

    @Operation(summary = "启动配置（注册门槛、国家、兴趣标签选项、VIP 产品展示配置）")
    @GetMapping("/init")
    AppBootstrapVO init(@RequestParam(value = "lang", required = false) String lang);
}
