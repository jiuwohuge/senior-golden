package cn.nine.pros.post.client.api.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.db.UserDTO;
import cn.nine.pros.post.client.model.input.admin.DeviceBlockInDto;
import cn.nine.pros.post.client.model.input.admin.UserQueryInDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@Tag(name = "管理后台-用户管理API")
public interface AdminUserApi {

    @Operation(summary = "用户列表")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/user/list")
    PageData<UserDTO> listUsers(@RequestBody @Validated UserQueryInDto query);

    @Operation(summary = "封禁用户")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/user/{id}/ban")
    void banUser(@PathVariable("id") Long id);

    @Operation(summary = "解封用户")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/user/{id}/unban")
    void unbanUser(@PathVariable("id") Long id);

    @Operation(summary = "拉黑设备")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/device/block")
    void blockDevice(@RequestBody @Validated DeviceBlockInDto req);
}