package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.pros.post.biz.model.domain.AdminUserDomain;
import cn.nine.pros.post.biz.model.mapstruct.AdminUserMapstruct;
import cn.nine.pros.post.biz.service.base.AdminUserService;
import cn.nine.pros.post.client.api.admin.AdminAuthApi;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.db.AdminUserDTO;
import cn.nine.pros.post.client.model.input.admin.LoginInDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@Slf4j
@RestController
@RequiredArgsConstructor
@Tag(name = "管理后台-认证API")
public class AdminAuthController implements AdminAuthApi {

    private final AdminUserService adminUserService;
    private final AdminUserMapstruct adminUserMapstruct;

    @Override
    @Operation(summary = "管理员登录")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/auth/login")
    public Map<String, Object> login(@RequestBody LoginInDto loginReq) {
        AdminUserDomain admin = adminUserService.getOne(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<AdminUserDomain>()
                        .eq(AdminUserDomain::getUsername, loginReq.getUsername())
                        .eq(AdminUserDomain::isDelFlag, false)
        );

        if (admin == null) {
            throw new cn.nine.commons.basic.exception.BadRequestException("用户名或密码错误");
        }

        if (!"1".equals(String.valueOf(admin.getStatus()))) {
            throw new cn.nine.commons.basic.exception.BadRequestException("账号已被禁用");
        }

        String token = java.util.UUID.randomUUID().toString().replace("-", "");

        admin.setLastLoginAt(LocalDateTime.now());
        admin.setLastLoginIp(MyRequestContextHolder.ipAddress());
        adminUserService.updateById(admin);

        Map<String, Object> result = new HashMap<>();
        result.put("token", token);
        result.put("admin", adminUserMapstruct.toDTO(admin));
        return result;
    }

    @Override
    @Operation(summary = "管理员登出")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/auth/logout")
    public void logout() {
    }

    @Override
    @Operation(summary = "获取当前管理员信息")
    @GetMapping(AppServiceDefine.WEBAPI_PREFIX + "/auth/current")
    public AdminUserDTO getCurrentAdmin() {
        Long adminId = MyRequestContextHolder.userIdNum();
        if (adminId == null) {
            return null;
        }
        return adminUserService.findById(adminId);
    }
}