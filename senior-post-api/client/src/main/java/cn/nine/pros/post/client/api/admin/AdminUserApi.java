package cn.nine.pros.post.client.api.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.db.UserDTO;
import cn.nine.pros.post.client.model.db.UserDeviceDTO;
import cn.nine.pros.post.client.model.input.admin.AdminIdListInDto;
import cn.nine.pros.post.client.model.input.admin.AdminUserBatchStatusInDto;
import cn.nine.pros.post.client.model.input.admin.AdminUserQuotaAdjustInDto;
import cn.nine.pros.post.client.model.input.admin.AdminUserSaveInDto;
import cn.nine.pros.post.client.model.input.admin.AdminUserVipDebugInDto;
import cn.nine.pros.post.client.model.input.admin.DeviceBlockInDto;
import cn.nine.pros.post.client.model.input.admin.UserQueryInDto;
import cn.nine.pros.post.client.model.out.AdminUserBriefVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "管理后台-用户")
@RequestMapping(AppServiceDefine.WEBAPI_PREFIX + "/user")
public interface AdminUserApi {

    @Operation(summary = "分页查询用户")
    @PostMapping("/paging")
    PageData<UserDTO> paging(@RequestBody @Valid UserQueryInDto body);

    @Operation(summary = "用户详情（含当日额度）")
    @GetMapping("/{id}")
    UserDTO detail(@PathVariable("id") Long id);

    @Operation(summary = "批量用户摘要（头像+昵称）")
    @PostMapping("/briefs")
    List<AdminUserBriefVO> briefs(@RequestBody @Valid AdminIdListInDto body);

    @Operation(summary = "设置用户状态")
    @PostMapping("/{id}/status")
    void updateStatus(@PathVariable("id") Long id, @RequestParam("status") Integer status);

    @Operation(summary = "批量设置用户状态")
    @PostMapping("/batch-status")
    void batchStatus(@RequestBody @Valid AdminUserBatchStatusInDto body);

    @Operation(summary = "编辑用户")
    @PostMapping("/save")
    void save(@RequestBody @Valid AdminUserSaveInDto body);

    @Operation(summary = "删除用户")
    @PostMapping("/{id}/delete")
    void delete(@PathVariable("id") Long id);

    @Operation(summary = "头像审核通过")
    @PostMapping("/{id}/avatar/approve")
    void approveAvatar(@PathVariable("id") Long id);

    @Operation(summary = "头像审核驳回")
    @PostMapping("/{id}/avatar/reject")
    void rejectAvatar(@PathVariable("id") Long id);

    @Operation(summary = "批量头像审核通过")
    @PostMapping("/avatar/batch-approve")
    void batchApproveAvatar(@RequestBody @Valid AdminIdListInDto body);

    @Operation(summary = "批量头像审核驳回")
    @PostMapping("/avatar/batch-reject")
    void batchRejectAvatar(@RequestBody @Valid AdminIdListInDto body);

    @Operation(summary = "调整用户当日免费发信剩余额度")
    @PostMapping("/{id}/quota/adjust")
    UserDTO adjustQuota(@PathVariable("id") Long id, @RequestBody @Valid AdminUserQuotaAdjustInDto body);

    @Operation(summary = "设备拉黑")
    @PostMapping("/device/block")
    void blockDevice(@RequestBody @Valid DeviceBlockInDto body);

    @Operation(summary = "用户名下设备列表（运营选设备拉黑）")
    @GetMapping("/{userId}/devices")
    List<UserDeviceDTO> listUserDevices(@PathVariable("userId") Long userId);

    @Operation(summary = "获取当前管理员")
    @GetMapping("/current-admin")
    UserDTO currentAdmin();

    @Operation(summary = "调试：设置用户 VIP 状态与过期时间")
    @PostMapping("/{id}/vip-debug")
    void updateVipDebug(@PathVariable("id") Long id, @RequestBody @Valid AdminUserVipDebugInDto body);
}
