package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.biz.service.biz.admin.AdminUserBizService;
import cn.nine.pros.post.client.api.admin.AdminUserApi;
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
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class AdminUserController implements AdminUserApi {

    private final AdminUserBizService adminUserBizService;

    @Override
    public PageData<UserDTO> paging(UserQueryInDto body) {
        return adminUserBizService.paging(body);
    }

    @Override
    public UserDTO detail(Long id) {
        return adminUserBizService.detail(id);
    }

    @Override
    public List<AdminUserBriefVO> briefs(AdminIdListInDto body) {
        return adminUserBizService.briefs(body);
    }

    @Override
    public void updateStatus(Long id, Integer status) {
        adminUserBizService.updateStatus(id, status);
    }

    @Override
    public void batchStatus(AdminUserBatchStatusInDto body) {
        adminUserBizService.batchStatus(body);
    }

    @Override
    public void save(AdminUserSaveInDto body) {
        adminUserBizService.save(body);
    }

    @Override
    public void delete(Long id) {
        adminUserBizService.delete(id);
    }

    @Override
    public void approveAvatar(Long id) {
        adminUserBizService.approveAvatar(id);
    }

    @Override
    public void rejectAvatar(Long id) {
        adminUserBizService.rejectAvatar(id);
    }

    @Override
    public void batchApproveAvatar(AdminIdListInDto body) {
        adminUserBizService.batchApproveAvatar(body);
    }

    @Override
    public void batchRejectAvatar(AdminIdListInDto body) {
        adminUserBizService.batchRejectAvatar(body);
    }

    @Override
    public UserDTO adjustQuota(Long id, AdminUserQuotaAdjustInDto body) {
        return adminUserBizService.adjustQuota(id, body);
    }

    @Override
    public void updateVipDebug(Long id, AdminUserVipDebugInDto body) {
        adminUserBizService.updateVipDebug(id, body);
    }

    @Override
    public void blockDevice(DeviceBlockInDto body) {
        adminUserBizService.blockDevice(body);
    }

    @Override
    public List<UserDeviceDTO> listUserDevices(Long userId) {
        return adminUserBizService.listUserDevices(userId);
    }

    @Override
    public UserDTO currentAdmin() {
        return adminUserBizService.currentAdmin();
    }
}
