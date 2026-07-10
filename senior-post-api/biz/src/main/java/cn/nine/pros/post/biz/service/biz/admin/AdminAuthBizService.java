package cn.nine.pros.post.biz.service.biz.admin;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.commons.web.filter.adapter.RedisCacheAdapter;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.model.domain.UserDomain;
import cn.nine.pros.post.biz.model.domain.UserIdentityDomain;
import cn.nine.pros.post.biz.service.base.UserIdentityService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.biz.service.biz.AppJwtService;
import cn.nine.pros.post.client.common.constant.AuthProvider;
import cn.nine.pros.post.client.model.db.UserDTO;
import cn.nine.pros.post.client.model.input.admin.LoginInDto;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

/**
 * 管理端登录鉴权：控制台账号登录、登出与当前管理员资料。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AdminAuthBizService {

    private final UserService userService;
    private final UserIdentityService userIdentityService;
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

    /**
     * 管理端登录：校验员工身份与密码后签发 Token。
     */
    public Map<String, Object> login(LoginInDto loginReq) {
        String email = resolveConsoleLoginEmail(loginReq.getUsername()).toLowerCase();
        UserIdentityDomain ident = userIdentityService.findActiveByProviderUid(AuthProvider.EMAIL, email);
        if (ident == null || !org.springframework.util.StringUtils.hasText(ident.getPasswordHash())) {
            log.info("admin login rejected: bad credential (identity missing)");
            throw new BadRequestException(appMessages.get("admin.error.auth.badCredential"));
        }
        UserDomain user = userService.getById(ident.getUserId());
        if (!canLoginConsole(user) || Boolean.TRUE.equals(user.isDelFlag())) {
            log.info("admin login rejected: not staff or deleted, userId={}", ident.getUserId());
            throw new BadRequestException(appMessages.get("admin.error.auth.badCredential"));
        }
        if (user.getStatus() != null && !"1".equals(String.valueOf(user.getStatus()))) {
            log.info("admin login rejected: account disabled, userId={}", user.getId());
            throw new BadRequestException(appMessages.get("admin.error.auth.accountDisabled"));
        }
        String raw = loginReq.getPassword();
        String pwdHash = ident.getPasswordHash();
        boolean ok = raw != null && (raw.equals(pwdHash) || passwordEncoder.matches(raw, pwdHash));
        if (!ok) {
            log.info("admin login rejected: bad credential, userId={}", user.getId());
            throw new BadRequestException(appMessages.get("admin.error.auth.badCredential"));
        }

        Long userPk = user.getId();
        if (userPk == null) {
            throw new BadRequestException(appMessages.get("admin.error.auth.userDataCorrupt"));
        }
        userService.markLoginSuccess(userPk, null);

        Map<String, Object> result = new HashMap<>();
        result.put("token", appJwtService.createToken(userPk));
        UserDTO dto = userService.findById(userPk);
        if (dto != null) {
            dto.setPasswordHash(null);
        }
        result.put("admin", dto);
        log.info("admin login ok, userId={}", userPk);
        return result;
    }

    /**
     * 管理端登出：清除当前 Token 缓存。
     */
    public void logout() {
        redisCacheAdapter.clearCache(MyRequestContextHolder.getContext().getToken());
        log.info("admin logout, userId={}", MyRequestContextHolder.userId());
    }

    /**
     * 返回当前登录管理员资料；非员工返回 null。
     */
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
