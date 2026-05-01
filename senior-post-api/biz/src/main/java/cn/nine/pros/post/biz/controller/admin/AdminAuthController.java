package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.commons.basic.util.TokenResolver;
import cn.nine.commons.web.filter.adapter.RedisCacheAdapter;
import cn.nine.pros.post.biz.model.domain.UserDomain;
import cn.nine.pros.post.biz.model.mapstruct.UserMapstruct;
import cn.nine.pros.post.biz.service.app.AppJwtService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.client.api.admin.AdminAuthApi;
import cn.nine.pros.post.client.model.db.UserDTO;
import cn.nine.pros.post.client.model.input.admin.LoginInDto;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequiredArgsConstructor
public class AdminAuthController implements AdminAuthApi {

    private final UserService userService;
    private final UserMapstruct userMapstruct;
    private final PasswordEncoder passwordEncoder;
    private final AppJwtService appJwtService;
    private final RedisCacheAdapter redisCacheAdapter;

    /** 管理端登录框可为完整邮箱，或短名（自动补全 {@code @staff.local}）。 */
    private static String resolveConsoleLoginEmail(String usernameOrEmail) {
        if (usernameOrEmail == null) {
            return "";
        }
        String t = usernameOrEmail.trim();
        if (t.isEmpty()) {
            return t;
        }
        return t.contains("@") ? t : t + "@staff.local";
    }

    /** {@code staff_role != 0} 表示可登录管理端（暂不分角色层级）。 */
    private static boolean canLoginConsole(UserDomain u) {
        return u != null && u.getStaffRole() != null && u.getStaffRole() != 0;
    }

    @Override
    public Map<String, Object> login(LoginInDto loginReq) {
        String email = resolveConsoleLoginEmail(loginReq.getUsername()).toLowerCase();
        UserDomain user = userService.getOne(new LambdaQueryWrapper<UserDomain>()
                .eq(UserDomain::getEmail, email)
                .eq(UserDomain::isDelFlag, false));
        if (!canLoginConsole(user)) {
            throw new BadRequestException("用户名或密码错误");
        }
        if (user.getStatus() != null && !"1".equals(String.valueOf(user.getStatus()))) {
            throw new BadRequestException("账号已被禁用");
        }
        String raw = loginReq.getPassword();
        String pwdHash = user.getPasswordHash();
        boolean ok = raw != null && (raw.equals(pwdHash) || passwordEncoder.matches(raw, pwdHash));
        if (!ok) {
            throw new BadRequestException("用户名或密码错误");
        }

        userService.update(new LambdaUpdateWrapper<UserDomain>()
                .eq(UserDomain::getId, user.getId())
                .set(UserDomain::getLastLoginAt, LocalDateTime.now())
                .set(UserDomain::getUpdatedAt, LocalDateTime.now()));

        Long userPk = user.getId();
        if (userPk == null) {
            throw new BadRequestException("用户数据异常");
        }
        Map<String, Object> result = new HashMap<>();
        result.put("token", appJwtService.createToken(userPk));
        UserDomain fresh = userService.getById(userPk);
        UserDTO dto = fresh == null ? null : userMapstruct.toDTO(fresh);
        if (dto != null) {
            dto.setPasswordHash(null);
        }
        result.put("admin", dto);
        return result;
    }

    @Override
    public void logout() {
        redisCacheAdapter.clearCache(MyRequestContextHolder.getContext().getToken());
    }

    @Override
    public UserDTO getCurrentAdmin() {
        Long uid = MyRequestContextHolder.userId();
        if (uid == null) {
            return null;
        }
        UserDomain user = userService.getById(uid);
        if (!canLoginConsole(user)) {
            return null;
        }
        UserDTO dto = userMapstruct.toDTO(user);
        if (dto != null) {
            dto.setPasswordHash(null);
        }
        return dto;
    }
}
