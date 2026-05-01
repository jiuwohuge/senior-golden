package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.model.domain.AdminUserDomain;
import cn.nine.pros.post.biz.model.mapstruct.AdminUserMapstruct;
import cn.nine.pros.post.biz.service.base.AdminUserService;
import cn.nine.pros.post.client.api.admin.AdminAuthApi;
import cn.nine.pros.post.client.model.db.AdminUserDTO;
import cn.nine.pros.post.client.model.input.admin.LoginInDto;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@RestController
@RequiredArgsConstructor
public class AdminAuthController implements AdminAuthApi {

    private final AdminUserService adminUserService;
    private final AdminUserMapstruct adminUserMapstruct;
    private final PasswordEncoder passwordEncoder;

    @Override
    public Map<String, Object> login(LoginInDto loginReq) {
        AdminUserDomain admin = adminUserService.getOne(new LambdaQueryWrapper<AdminUserDomain>()
                .eq(AdminUserDomain::getUsername, loginReq.getUsername())
                .eq(AdminUserDomain::isDelFlag, false));
        if (admin == null) {
            throw new BadRequestException("用户名或密码错误");
        }
        if (admin.getStatus() != null && !"1".equals(String.valueOf(admin.getStatus()))) {
            throw new BadRequestException("账号已被禁用");
        }
        String raw = loginReq.getPassword();
        String pwdHash = admin.getPasswordHash();
        boolean ok = raw != null && (raw.equals(pwdHash) || passwordEncoder.matches(raw, pwdHash));
        if (!ok) {
            throw new BadRequestException("用户名或密码错误");
        }

        admin.setLastLoginAt(LocalDateTime.now());
        admin.setLastLoginIp(MyRequestContextHolder.ipAddress());
        adminUserService.updateById(admin);

        Map<String, Object> result = new HashMap<>();
        result.put("token", UUID.randomUUID().toString().replace("-", ""));
        result.put("admin", adminUserMapstruct.toDTO(admin));
        return result;
    }

    @Override
    public void logout() {
    }

    @Override
    public AdminUserDTO getCurrentAdmin() {
        Long adminId = MyRequestContextHolder.userIdNum();
        if (adminId == null) {
            return null;
        }
        AdminUserDomain admin = adminUserService.getById(adminId);
        return admin == null ? null : adminUserMapstruct.toDTO(admin);
    }
}
