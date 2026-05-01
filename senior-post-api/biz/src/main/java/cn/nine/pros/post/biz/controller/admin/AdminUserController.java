package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.model.domain.AdminUserDomain;
import cn.nine.pros.post.biz.model.domain.UserDeviceDomain;
import cn.nine.pros.post.biz.model.domain.UserDomain;
import cn.nine.pros.post.biz.model.mapstruct.AdminUserMapstruct;
import cn.nine.pros.post.biz.model.mapstruct.UserMapstruct;
import cn.nine.pros.post.biz.service.base.AdminUserService;
import cn.nine.pros.post.biz.service.base.UserDeviceService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.client.api.admin.AdminUserApi;
import cn.nine.pros.post.client.model.db.AdminUserDTO;
import cn.nine.pros.post.client.model.db.UserDTO;
import cn.nine.pros.post.client.model.input.admin.DeviceBlockInDto;
import cn.nine.pros.post.client.model.input.admin.UserQueryInDto;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.apache.commons.lang3.StringUtils;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequiredArgsConstructor
public class AdminUserController implements AdminUserApi {

    private final UserService userService;
    private final UserMapstruct userMapstruct;
    private final UserDeviceService userDeviceService;
    private final AdminUserService adminUserService;
    private final AdminUserMapstruct adminUserMapstruct;

    @Override
    public PageData<UserDTO> paging(UserQueryInDto body) {
        PageQuery pageQuery = AdminPageHelper.normalize(body.getPage());
        LambdaQueryWrapper<UserDomain> qw = new LambdaQueryWrapper<UserDomain>()
                .eq(UserDomain::isDelFlag, false)
                .orderByDesc(UserDomain::getCreatedAt);
        if (StringUtils.isNotBlank(body.getEmail())) {
            qw.like(UserDomain::getEmail, body.getEmail().trim());
        }
        if (StringUtils.isNotBlank(body.getNickname())) {
            qw.like(UserDomain::getNickname, body.getNickname().trim());
        }
        if (body.getStatus() != null) {
            qw.eq(UserDomain::getStatus, body.getStatus());
        }
        Page<UserDomain> p = userService.page(AdminPageHelper.mpPage(pageQuery), qw);
        List<UserDTO> list = p.getRecords().stream().map(userMapstruct::toDTO).collect(Collectors.toList());
        return AdminPageHelper.pageData(pageQuery, p, list);
    }

    @Override
    public void updateStatus(Long id, Integer status) {
        if (status == null || (status != 1 && status != 2 && status != 3)) {
            throw new BadRequestException("非法状态值");
        }
        userService.update(new LambdaUpdateWrapper<UserDomain>()
                .eq(UserDomain::getId, id)
                .set(UserDomain::getStatus, status)
                .set(UserDomain::getUpdatedBy, MyRequestContextHolder.userId())
                .set(UserDomain::getUpdatedAt, java.time.LocalDateTime.now()));
    }

    @Override
    public void blockDevice(DeviceBlockInDto body) {
        userDeviceService.update(new LambdaUpdateWrapper<UserDeviceDomain>()
                .eq(UserDeviceDomain::getDeviceUuid, body.getDeviceUuid())
                .eq(UserDeviceDomain::isDelFlag, false)
                .set(UserDeviceDomain::getStatus, 2)
                .set(UserDeviceDomain::getUpdatedBy, MyRequestContextHolder.userId())
                .set(UserDeviceDomain::getUpdatedAt, java.time.LocalDateTime.now()));
    }

    @Override
    public AdminUserDTO currentAdmin() {
        Long adminId = MyRequestContextHolder.userIdNum();
        if (adminId == null) {
            return null;
        }
        AdminUserDomain d = adminUserService.getById(adminId);
        return d == null ? null : adminUserMapstruct.toDTO(d);
    }
}
