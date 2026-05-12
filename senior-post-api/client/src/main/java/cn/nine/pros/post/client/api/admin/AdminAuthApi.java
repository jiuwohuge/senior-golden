package cn.nine.pros.post.client.api.admin;

import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.db.UserDTO;
import cn.nine.pros.post.client.model.input.admin.LoginInDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.Map;

@Tag(name = "管理后台-认证")
@RequestMapping(AppServiceDefine.WEBAPI_PREFIX + "/auth")
public interface AdminAuthApi {

    @Operation(summary = "管理员登录")
    @PostMapping("/login")
    Map<String, Object> login(@RequestBody @Valid LoginInDto loginReq);

    @Operation(summary = "管理员登出")
    @PostMapping("/logout")
    void logout();

    @Operation(summary = "获取当前管理员信息")
    @GetMapping("/current")
    UserDTO getCurrentAdmin();
}
