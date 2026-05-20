package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.commons.basic.util.TokenResolver;
import cn.nine.commons.web.filter.adapter.RedisCacheAdapter;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.model.domain.UserDomain;
import cn.nine.pros.post.biz.model.domain.UserIdentityDomain;
import cn.nine.pros.post.biz.model.mapstruct.UserMapstruct;
import cn.nine.pros.post.biz.service.app.AppJwtService;
import cn.nine.pros.post.biz.service.base.UserIdentityService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.client.api.admin.AdminAuthApi;
import cn.nine.pros.post.client.common.constant.AuthProvider;
import cn.nine.pros.post.client.model.db.UserDTO;
import cn.nine.pros.post.client.model.input.admin.LoginInDto;
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
    private final UserIdentityService userIdentityService;
    private final UserMapstruct userMapstruct;
    private final PasswordEncoder passwordEncoder;
    private final AppJwtService appJwtService;
    private final RedisCacheAdapter redisCacheAdapter;
    private final AppMessages appMessages;

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

    private static boolean canLoginConsole(UserDomain u) {
        return u != null && u.getStaffRole() != null && u.getStaffRole() != 0;
    }

    @Override
    public Map<String, Object> login(LoginInDto loginReq) {
        String email = resolveConsoleLoginEmail(loginReq.getUsername()).toLowerCase();
        UserIdentityDomain ident = userIdentityService.findActiveByProviderUid(AuthProvider.EMAIL, email);
        if (ident == null || !org.springframework.util.StringUtils.hasText(ident.getPasswordHash())) {
            throw new BadRequestException(appMessages.get("admin.error.auth.badCredential"));
        }
        UserDomain user = userService.getById(ident.getUserId());
        if (!canLoginConsole(user) || Boolean.TRUE.equals(user.isDelFlag())) {
            throw new BadRequestException(appMessages.get("admin.error.auth.badCredential"));
        }
        if (user.getStatus() != null && !"1".equals(String.valueOf(user.getStatus()))) {
            throw new BadRequestException(appMessages.get("admin.error.auth.accountDisabled"));
        }
        String raw = loginReq.getPassword();
        String pwdHash = ident.getPasswordHash();
        boolean ok = raw != null && (raw.equals(pwdHash) || passwordEncoder.matches(raw, pwdHash));
        if (!ok) {
            throw new BadRequestException(appMessages.get("admin.error.auth.badCredential"));
        }

        userService.update(new LambdaUpdateWrapper<UserDomain>()
                .eq(UserDomain::getId, user.getId())
                .set(UserDomain::getLastLoginAt, LocalDateTime.now())
                .set(UserDomain::getUpdatedAt, LocalDateTime.now()));

        Long userPk = user.getId();
        if (userPk == null) {
            throw new BadRequestException(appMessages.get("admin.error.auth.userDataCorrupt"));
        }
        Map<String, Object> result = new HashMap<>();
        result.put("token", appJwtService.createToken(userPk));
        UserDTO dto = userService.findById(userPk);
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
        UserDTO dto = userService.findById(uid);
        if (dto != null) {
            dto.setPasswordHash(null);
        }
        return dto;
    }
}
