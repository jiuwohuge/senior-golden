package cn.nine.pros.post.client.api.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.db.UserDTO;
import cn.nine.pros.post.client.model.db.UserDeviceDTO;
import cn.nine.pros.post.client.model.input.admin.AdminUserVipDebugInDto;
import cn.nine.pros.post.client.model.input.admin.DeviceBlockInDto;
import cn.nine.pros.post.client.model.input.admin.UserQueryInDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "管理后台-用户")
public interface AdminUserApi {

    @Operation(summary = "分页查询用户")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/user/paging")
    PageData<UserDTO> paging(@RequestBody @Valid UserQueryInDto body);

    @Operation(summary = "设置用户状态")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/user/{id}/status")
    void updateStatus(@PathVariable("id") Long id, @RequestParam("status") Integer status);

    @Operation(summary = "设备拉黑")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/user/device/block")
    void blockDevice(@RequestBody @Valid DeviceBlockInDto body);

    @Operation(summary = "用户名下设备列表（运营选设备拉黑）")
    @GetMapping(AppServiceDefine.WEBAPI_PREFIX + "/user/{userId}/devices")
    List<UserDeviceDTO> listUserDevices(@PathVariable("userId") Long userId);

    @Operation(summary = "获取当前管理员")
    @GetMapping(AppServiceDefine.WEBAPI_PREFIX + "/user/current-admin")
    UserDTO currentAdmin();

    @Operation(summary = "调试：设置用户 VIP 状态与过期时间")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/user/{id}/vip-debug")
    void updateVipDebug(@PathVariable("id") Long id, @RequestBody @Valid AdminUserVipDebugInDto body);
}
