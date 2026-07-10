package cn.nine.pros.post.client.api.app;

import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.out.ProfileOverviewVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Tag(name = "App-个人中心")
@RequestMapping(AppServiceDefine.SERVER_PREFIX + "/profile")
public interface AppProfileApi {

    @Operation(summary = "个人中心概览统计（§13）")
    @GetMapping("/overview")
    ProfileOverviewVO overview();
}
