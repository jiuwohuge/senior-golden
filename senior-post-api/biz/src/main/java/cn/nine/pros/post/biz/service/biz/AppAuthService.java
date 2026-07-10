package cn.nine.pros.post.biz.service.biz;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.context.RequestContext;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.config.OssProperties;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.model.domain.LoginDomain;
import cn.nine.pros.post.biz.model.domain.TagDomain;
import cn.nine.pros.post.biz.model.domain.UserDeviceDomain;
import cn.nine.pros.post.biz.model.domain.UserDomain;
import cn.nine.pros.post.biz.model.domain.UserIdentityDomain;
import cn.nine.pros.post.biz.service.biz.support.AppAuthProfileSupport;
import cn.nine.pros.post.biz.service.biz.support.GeoIpLookup;
import cn.nine.pros.post.biz.service.biz.support.GoogleIdTokenVerifierService;
import cn.nine.pros.post.biz.service.biz.support.GoogleIdTokenVerifierService.VerifiedGoogleIdentity;
import cn.nine.pros.post.biz.service.biz.support.LoginRiskEvaluator;
import cn.nine.pros.post.biz.service.biz.support.OssReadableKeyValidator;
import cn.nine.pros.post.biz.service.biz.support.UserAvatarAuditSupport;
import cn.nine.pros.post.biz.service.biz.support.UserInterestAssembler;
import cn.nine.pros.post.biz.service.base.FriendshipService;
import cn.nine.pros.post.biz.service.base.LoginService;
import cn.nine.pros.post.biz.service.base.OssDisplayUrlService;
import cn.nine.pros.post.biz.service.base.TagService;
import cn.nine.pros.post.biz.service.base.UserDeviceService;
import cn.nine.pros.post.biz.service.base.UserIdentityService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.biz.service.base.UserTagService;
import cn.nine.pros.post.client.common.constant.AuthProvider;
import cn.nine.pros.post.client.common.constant.UserGender;
import cn.nine.pros.post.client.model.db.UserDTO;
import cn.nine.pros.post.client.model.input.AppAuthProfilePatchInDto;
import cn.nine.pros.post.client.model.input.AppForgotPasswordInDto;
import cn.nine.pros.post.client.model.input.AppGoogleCompleteInDto;
import cn.nine.pros.post.client.model.input.AppGoogleLoginInDto;
import cn.nine.pros.post.client.model.input.AppLoginChallengeConfirmInDto;
import cn.nine.pros.post.client.model.input.AppLoginInDto;
import cn.nine.pros.post.client.model.input.AppRegisterInDto;
import cn.nine.pros.post.client.model.input.AppResetPasswordInDto;
import cn.nine.pros.post.client.model.out.AppAuthResultVO;
import cn.nine.pros.post.client.model.out.AppPublicUserVO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.i18n.LocaleContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.time.Year;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Objects;
import java.util.Set;

/**
 * App 认证与资料：注册/登录/Google/密码重置/注销申请/资料补丁。
 * <p>写路径成功打 INFO；鉴权拒绝与风控拦截打 INFO/WARN（不记录密码、Token、邮箱全文）。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AppAuthService {

    private static final int MIN_AGE = 45;
    private static final int ACCOUNT_DELETION_COOLDOWN_DAYS = 7;
    private static final int LOGIN_SUCCESS = 1;
    private static final int LOGIN_FAIL = 2;

    private final UserService userService;
    private final UserIdentityService userIdentityService;
    private final UserDeviceService userDeviceService;
    private final PasswordEncoder passwordEncoder;
    private final AppJwtService appJwtService;
    private final OssDisplayUrlService ossDisplayUrlService;
    private final PasswordResetService passwordResetService;
    private final OssProperties ossProperties;
    private final UserTagService userTagService;
    private final TagService tagService;
    private final UserInterestAssembler userInterestAssembler;
    private final FriendshipService friendshipService;
    private final AppMessages appMessages;
    private final GoogleIdTokenVerifierService googleIdTokenVerifierService;
    private final LoginService loginService;
    private final GeoIpService geoIpService;
    private final EmailVerifyService emailVerifyService;

    /**
     * 邮箱注册：校验年龄/兴趣标签后建用户与邮箱身份，并完成首次登录发 Token。
     * <p>前置：邮箱未占用、年龄≥45、兴趣标签合法；副作用：写 user/identity/tags/device/login。
     */
    @Transactional(rollbackFor = Exception.class)
    public AppAuthResultVO register(AppRegisterInDto body) {
        assertGenderValid(body.getGender());
        String email = body.getEmail().trim().toLowerCase();
        if (userIdentityService.findActiveEmailByUid(email) != null) {
            throw new BadRequestException(appMessages.get("app.error.register.emailTaken"));
        }
        int currentYear = Year.now().getValue();
        int age = currentYear - body.getBirthYear();
        if (age < MIN_AGE) {
            throw new BadRequestException(appMessages.get("app.error.register.minAge", MIN_AGE));
        }
        List<Integer> regTagIds = body.getInterestTagIds();
        assertInterestTagIdsValidForReplace(regTagIds);

        UserDomain user = new UserDomain();
        user.setGender(body.getGender());
        user.setNickname(body.getNickname().trim());
        user.setBirthYear(body.getBirthYear());
        user.setCountryCode(body.getCountryCode() != null ? body.getCountryCode().trim() : null);
        user.setBio(null);
        user.setAvatarUrl(null);
        user.setIsVip(false);
        user.setStatus(1);
        user.setStaffRole(0);
        user.setEmailVerified(false);
        user.setLanguage(resolveClientLanguageTag());
        user.setDelFlag(false);
        LocalDateTime now = LocalDateTime.now();
        user.setCreatedAt(now);
        user.setUpdatedAt(now);
        user.setCreatedBy(0L);
        user.setUpdatedBy(0L);
        user.setLastLoginAt(now);
        String registerIp = MyRequestContextHolder.ipAddress();
        user.setRegisterIp(registerIp);
        applyGeoToUser(user, geoIpService.resolve(registerIp), true);
        userService.save(user);
        applyRegisterAvatarIfPresent(user.getId(), body.getAvatarUrl());

        userIdentityService.createEmailIdentity(
                user.getId(), email, passwordEncoder.encode(body.getPassword()), user.getId());

        userTagService.replaceUserTags(user.getId(), user.getId(), new ArrayList<>(new LinkedHashSet<>(regTagIds)));
        String deviceUuid = assertDeviceUuidMatchesHeaderOrBody(body.getDeviceUuid());
        touchDevice(user.getId(), deviceUuid, normalizeDeviceType(body.getDeviceType()));
        recordLogin(user.getId(), deviceUuid, LOGIN_SUCCESS, null, LoginRiskEvaluator.RISK_NONE);
        log.info("user registered, userId={}", user.getId());
        return finishAuth(user.getId(), true, LoginRiskEvaluator.RISK_NONE, false);
    }

    /**
     * 邮箱密码登录：校验凭证与账号状态后进入风控门并发 Token（或要求二次验证）。
     * <p>前置：设备头体一致；副作用：写 login 流水、可能更新设备/地理/语言。
     */
    @Transactional(rollbackFor = Exception.class)
    public AppAuthResultVO login(AppLoginInDto body) {
        String email = body.getEmail().trim().toLowerCase();
        String deviceUuid;
        try {
            deviceUuid = assertDeviceUuidMatchesHeaderOrBody(body.getDeviceUuid());
        } catch (BadRequestException e) {
            recordLogin(null, body.getDeviceUuid(), LOGIN_FAIL, "device_mismatch", LoginRiskEvaluator.RISK_NONE);
            log.info("login rejected: device header/body mismatch");
            throw e;
        }
        UserIdentityDomain ident = userIdentityService.findActiveEmailByUid(email);
        if (ident == null || !StringUtils.hasText(ident.getPasswordHash())) {
            recordLogin(null, deviceUuid, LOGIN_FAIL, "bad_credential", LoginRiskEvaluator.RISK_NONE);
            log.info("login rejected: bad credential (identity missing)");
            throw new BadRequestException(appMessages.get("app.error.login.badCredential"));
        }
        if (!passwordEncoder.matches(body.getPassword(), ident.getPasswordHash())) {
            recordLogin(ident.getUserId(), deviceUuid, LOGIN_FAIL, "bad_credential", LoginRiskEvaluator.RISK_NONE);
            log.info("login rejected: bad credential, userId={}", ident.getUserId());
            throw new BadRequestException(appMessages.get("app.error.login.badCredential"));
        }
        UserDTO dto = userService.findById(ident.getUserId());
        if (dto == null) {
            recordLogin(ident.getUserId(), deviceUuid, LOGIN_FAIL, "user_missing", LoginRiskEvaluator.RISK_NONE);
            log.info("login rejected: user missing, userId={}", ident.getUserId());
            throw new BadRequestException(appMessages.get("app.error.login.badCredential"));
        }
        finalizeAccountDeletionIfCooldownElapsed(dto.getId());
        dto = userService.findById(dto.getId());
        if (dto == null) {
            recordLogin(ident.getUserId(), deviceUuid, LOGIN_FAIL, "user_missing", LoginRiskEvaluator.RISK_NONE);
            log.info("login rejected: user missing after deletion finalize, userId={}", ident.getUserId());
            throw new BadRequestException(appMessages.get("app.error.login.badCredential"));
        }
        if (dto.getStatus() == null || !Integer.valueOf(1).equals(convertStatus(dto.getStatus()))) {
            recordLogin(dto.getId(), deviceUuid, LOGIN_FAIL, "unavailable", LoginRiskEvaluator.RISK_NONE);
            log.info("login rejected: account unavailable, userId={}", dto.getId());
            throw new BadRequestException(appMessages.get("app.error.account.unavailable"));
        }

        return completeSuccessfulLogin(dto, deviceUuid, normalizeDeviceType(body.getDeviceType()));
    }

    /**
     * 中风险登录二次验证通过后发放 Token。
     * <p>前置：邮箱验证码有效、账号可用；副作用：同成功登录写路径。
     */
    @Transactional(rollbackFor = Exception.class)
    public AppAuthResultVO confirmLoginChallenge(AppLoginChallengeConfirmInDto body) {
        long userId = emailVerifyService.confirmLoginChallenge(body.getEmail(), body.getCode());
        UserDTO dto = userService.findById(userId);
        if (dto == null || dto.getStatus() == null || !Integer.valueOf(1).equals(convertStatus(dto.getStatus()))) {
            throw new BadRequestException(appMessages.get("app.error.account.unavailable"));
        }
        String deviceUuid = assertDeviceUuidMatchesHeaderOrBody(body.getDeviceUuid());
        return completeSuccessfulLogin(dto, deviceUuid, normalizeDeviceType(body.getDeviceType()), true);
    }

    private AppAuthResultVO completeSuccessfulLogin(UserDTO dto, String deviceUuid, String deviceType) {
        return completeSuccessfulLogin(dto, deviceUuid, deviceType, false);
    }

    private AppAuthResultVO completeSuccessfulLogin(
            UserDTO dto, String deviceUuid, String deviceType, boolean skipRiskGate) {
        String ip = MyRequestContextHolder.ipAddress();
        GeoIpLookup geo = geoIpService.resolve(ip);
        applyGeoUpdateIfEmpty(dto.getId(), geo);

        List<LoginDomain> prev = loginService.listRecentSuccessfulByUserId(dto.getId(), 5);
        UserDomain freshDomain = userService.getById(dto.getId());
        Double prevLat = freshDomain != null ? freshDomain.getLatitude() : null;
        Double prevLng = freshDomain != null ? freshDomain.getLongitude() : null;
        Double curLat = preferGeoOrStored(geo.latitude(), prevLat);
        Double curLng = preferGeoOrStored(geo.longitude(), prevLng);

        LoginRiskEvaluator.RiskResult risk = resolveLoginRisk(
                skipRiskGate, geo, deviceUuid, curLat, curLng, prev, prevLat, prevLng);

        if (risk.level() == LoginRiskEvaluator.RISK_HIGH) {
            userService.updateStatus(dto.getId(), 2);
            recordLogin(dto.getId(), deviceUuid, LOGIN_FAIL, "risk_high", risk.level(), geo.countryCode());
            log.warn("high risk login banned userId={}, triggers={}", dto.getId(), risk.triggerCount());
            throw new BadRequestException(appMessages.get("app.error.login.riskHigh"));
        }

        if (risk.level() == LoginRiskEvaluator.RISK_MEDIUM && !skipRiskGate) {
            recordLogin(dto.getId(), deviceUuid, LOGIN_FAIL, "risk_medium_challenge", risk.level(), geo.countryCode());
            log.info("medium risk login challenge required, userId={}", dto.getId());
            UserInterestAssembler.Payload interests = userInterestAssembler.loadForUser(dto.getId());
            boolean complete = AppAuthProfileSupport.isProfileComplete(dto, interests.ids());
            return AppAuthResultVO.builder()
                    .token(null)
                    .user(toPublic(userService.findById(dto.getId()), dto.getId(), true))
                    .profileComplete(complete)
                    .riskLevel(risk.level())
                    .requireEmailChallenge(true)
                    .build();
        }

        userService.markLoginSuccess(
                dto.getId(),
                StringUtils.hasText(dto.getLanguage()) ? null : resolveClientLanguageTag());

        touchDevice(dto.getId(), deviceUuid, deviceType);
        recordLogin(dto.getId(), deviceUuid, LOGIN_SUCCESS, null, risk.level(), geo.countryCode());
        UserInterestAssembler.Payload interests = userInterestAssembler.loadForUser(dto.getId());
        boolean complete = AppAuthProfileSupport.isProfileComplete(
                userService.findById(dto.getId()), interests.ids());
        log.info("user login ok, userId={}, risk={}", dto.getId(), risk.level());
        return finishAuth(dto.getId(), complete, risk.level(), false);
    }

    /**
     * 注册前校验邮箱是否可用（已占用则抛错）。
     */
    public void validateRegisterEmail(String rawEmail) {
        String email = rawEmail.trim().toLowerCase();
        if (userIdentityService.findActiveEmailByUid(email) != null) {
            log.info("register email rejected: already taken");
            throw new BadRequestException(appMessages.get("app.error.register.emailTaken"));
        }
    }

    /**
     * Google 登录：校验 idToken 后解析/创建用户并走统一登录成功路径。
     * <p>前置：idToken 有效、账号可用；副作用：可能新建壳用户/挂 OAuth 身份，并写登录流水。
     */
    @Transactional(rollbackFor = Exception.class)
    public AppAuthResultVO loginWithGoogle(AppGoogleLoginInDto body) {
        VerifiedGoogleIdentity google = googleIdTokenVerifierService.verify(body.getIdToken());
        long userId = resolveOrCreateGoogleUserId(google);

        finalizeAccountDeletionIfCooldownElapsed(userId);
        UserDTO dto = userService.findById(userId);
        if (dto == null || dto.getStatus() == null || !Integer.valueOf(1).equals(convertStatus(dto.getStatus()))) {
            throw new BadRequestException(appMessages.get("app.error.account.unavailable"));
        }
        String deviceUuid = assertDeviceUuidMatchesHeaderOrBody(body.getDeviceUuid());
        return completeSuccessfulLogin(dto, deviceUuid, normalizeDeviceType(body.getDeviceType()));
    }

    /**
     * Google 新用户补全资料（性别/年龄/昵称/兴趣等）后发完整 Token。
     * <p>前置：已登录会话、年龄≥45、兴趣标签合法；副作用：更新 user 与 tags。
     */
    @Transactional(rollbackFor = Exception.class)
    public AppAuthResultVO completeGoogleProfile(AppGoogleCompleteInDto body) {
        Long uid = MyRequestContextHolder.userId();
        if (uid == null) {
            throw new BadRequestException(appMessages.get("app.error.session.invalid"));
        }
        assertGenderValid(body.getGender());
        int age = Year.now().getValue() - body.getBirthYear();
        if (age < MIN_AGE) {
            throw new BadRequestException(appMessages.get("app.error.register.minAge", MIN_AGE));
        }
        assertInterestTagIdsValidForReplace(body.getInterestTagIds());

        UserDomain onboarding = userService.getById(uid);
        if (onboarding == null) {
            throw new BadRequestException(appMessages.get("app.error.user.notFound"));
        }
        onboarding.setGender(body.getGender());
        onboarding.setBirthYear(body.getBirthYear());
        onboarding.setNickname(body.getNickname().trim());
        onboarding.setCountryCode(normalizeOptionalCountryCode(body.getCountryCode()));
        if (body.getAvatarUrl() != null) {
            applyAvatarPatchToDomain(onboarding, uid, body.getAvatarUrl());
        }
        onboarding.setUpdatedAt(LocalDateTime.now());
        onboarding.setUpdatedBy(uid);
        userService.updateById(onboarding);
        userTagService.replaceUserTags(uid, uid, new ArrayList<>(new LinkedHashSet<>(body.getInterestTagIds())));

        log.info("google profile completed, userId={}", uid);
        return finishAuth(uid, true, LoginRiskEvaluator.RISK_NONE, false);
    }

    /**
     * 忘记密码：向邮箱发重置码（OAuth-only 账号拒绝）。
     * <p>副作用：委托 PasswordResetService 写重置令牌/发信。
     */
    public void forgotPassword(AppForgotPasswordInDto body) {
        String email = body.getEmail().trim().toLowerCase();
        UserIdentityDomain ident = userIdentityService.findActiveEmailByUid(email);
        if (ident != null && userIdentityService.hasOAuthOnly(ident.getUserId())) {
            log.info("forgot-password rejected: oauth-only, userId={}", ident.getUserId());
            throw new BadRequestException(appMessages.get("app.error.password.oauthOnly"));
        }
        passwordResetService.requestForgotPassword(body.getEmail());
        log.info("forgot-password requested");
    }

    /**
     * 用验证码完成密码重置。
     * <p>副作用：更新密码哈希并失效重置令牌。
     */
    public void resetPassword(AppResetPasswordInDto body) {
        passwordResetService.completeReset(body.getEmail(), body.getCode(), body.getNewPassword());
        log.info("password reset completed");
    }

    /**
     * 当前登录用户公开资料；未登录返回 null，已删号抛错。
     */
    public AppPublicUserVO me() {
        Long uid = MyRequestContextHolder.userId();
        if (uid == null) {
            return null;
        }
        finalizeAccountDeletionIfCooldownElapsed(uid);
        UserDTO dto = userService.findById(uid);
        if (dto == null) {
            return null;
        }
        if (dto.getStatus() == null || !Integer.valueOf(1).equals(convertStatus(dto.getStatus()))) {
            throw new BadRequestException(appMessages.get("app.error.account.deleted"));
        }
        return toPublic(dto, dto.getId(), true);
    }

    /**
     * 申请注销账号：进入冷静期，到期后由登录路径 finalize。
     * <p>前置：已登录且状态正常；副作用：写 deletionRequestedAt。
     */
    @Transactional(rollbackFor = Exception.class)
    public void requestAccountDeletion() {
        Long uid = MyRequestContextHolder.userId();
        if (uid == null) {
            throw new BadRequestException(appMessages.get("app.error.session.invalid"));
        }
        UserDTO dto = userService.findById(uid);
        if (dto == null) {
            throw new BadRequestException(appMessages.get("app.error.user.notFound"));
        }
        if (dto.getStatus() == null || !Integer.valueOf(1).equals(convertStatus(dto.getStatus()))) {
            throw new BadRequestException(appMessages.get("app.error.account.deleteNotAllowed"));
        }
        userService.requestDeletion(uid);
        log.info("account deletion requested, userId={}", uid);
    }

    /**
     * 补丁更新当前用户资料（性别/昵称/国家/简介/头像/兴趣）。
     * <p>前置：已登录且至少一项可改字段；副作用：更新 user 和/或 tags。
     */
    @Transactional(rollbackFor = Exception.class)
    public AppPublicUserVO updateProfile(AppAuthProfilePatchInDto body) {
        Long uid = MyRequestContextHolder.userId();
        if (uid == null) {
            throw new BadRequestException(appMessages.get("app.error.session.invalid"));
        }
        UserDTO existing = userService.findById(uid);
        if (existing == null) {
            throw new BadRequestException(appMessages.get("app.error.user.notFound"));
        }
        boolean changed = false;
        boolean userRowChanged = false;
        UserDomain row = userService.getById(uid);
        if (row == null) {
            throw new BadRequestException(appMessages.get("app.error.user.notFound"));
        }
        if (body.getGender() != null) {
            assertGenderValid(body.getGender());
            row.setGender(body.getGender());
            changed = true;
            userRowChanged = true;
        }
        if (body.getNickname() != null) {
            applyNicknamePatch(row, body.getNickname());
            changed = true;
            userRowChanged = true;
        }
        if (body.getCountryCode() != null) {
            String c = body.getCountryCode().trim();
            row.setCountryCode(c.isEmpty() ? null : c);
            changed = true;
            userRowChanged = true;
        }
        if (body.getBio() != null) {
            row.setBio(body.getBio().trim());
            changed = true;
            userRowChanged = true;
        }
        if (body.getAvatarUrl() != null) {
            applyAvatarPatchToDomain(row, uid, body.getAvatarUrl());
            changed = true;
            userRowChanged = true;
        }
        if (body.getInterestTagIds() != null) {
            List<Integer> ids = body.getInterestTagIds();
            assertInterestTagIdsValidForReplace(ids);
            userTagService.replaceUserTags(uid, uid, new ArrayList<>(new LinkedHashSet<>(ids)));
            changed = true;
        }
        if (!changed) {
            throw new BadRequestException(appMessages.get("app.error.profile.nothingToUpdate"));
        }
        if (userRowChanged) {
            row.setUpdatedAt(LocalDateTime.now());
            row.setUpdatedBy(uid);
            userService.updateById(row);
        }
        log.info("profile updated, userId={}", uid);
        return toPublic(userService.findById(uid), uid, true);
    }

    /**
     * 解析或创建 Google 登录对应用户：已有 Google 身份 → 邮箱关联并挂 Google → 新建壳用户。
     */
    private long resolveOrCreateGoogleUserId(VerifiedGoogleIdentity google) {
        UserIdentityDomain existing = userIdentityService.findActiveByProviderUid(AuthProvider.GOOGLE, google.sub());
        if (existing != null) {
            return existing.getUserId();
        }
        if (!StringUtils.hasText(google.email())) {
            return createGoogleShellUser(google);
        }
        return linkGoogleToEmailOrCreateShell(google);
    }

    /** 用 Google 邮箱关联已有账号并写入 OAuth 身份；无邮箱身份则新建壳用户。 */
    private long linkGoogleToEmailOrCreateShell(VerifiedGoogleIdentity google) {
        UserIdentityDomain emailIdent = userIdentityService.findActiveEmailByUid(google.email());
        if (emailIdent == null) {
            return createGoogleShellUser(google);
        }
        long userId = emailIdent.getUserId();
        userIdentityService.createOAuthIdentity(userId, AuthProvider.GOOGLE, google.sub(), userId);
        return userId;
    }

    private long createGoogleShellUser(VerifiedGoogleIdentity google) {
        String nick = resolveGoogleNickname(google);
        LocalDateTime now = LocalDateTime.now();
        UserDomain user = new UserDomain();
        user.setGender(UserGender.UNSPECIFIED);
        user.setNickname(nick);
        user.setBirthYear(1970);
        user.setCountryCode(null);
        user.setBio(null);
        user.setAvatarUrl(null);
        user.setIsVip(false);
        user.setStatus(1);
        user.setStaffRole(0);
        user.setDelFlag(false);
        user.setCreatedAt(now);
        user.setUpdatedAt(now);
        user.setCreatedBy(0L);
        user.setUpdatedBy(0L);
        user.setLastLoginAt(now);
        user.setRegisterIp(MyRequestContextHolder.ipAddress());
        userService.save(user);
        userIdentityService.createOAuthIdentity(user.getId(), AuthProvider.GOOGLE, google.sub(), user.getId());
        if (StringUtils.hasText(google.email())) {
            userIdentityService.createEmailIdentity(
                    user.getId(), google.email(), null, user.getId());
        }
        return user.getId();
    }

    private AppAuthResultVO finishAuth(
            long userId, boolean profileComplete, int riskLevel, boolean requireChallenge) {
        String token = requireChallenge ? null : appJwtService.createToken(userId);
        UserDTO fresh = userService.findById(userId);
        return AppAuthResultVO.builder()
                .token(token)
                .user(toPublic(fresh, fresh.getId(), true))
                .profileComplete(profileComplete)
                .riskLevel(riskLevel)
                .requireEmailChallenge(requireChallenge)
                .build();
    }

    /** 注册成功后若请求带头像 URL，则写入并标记待审。 */
    private void applyRegisterAvatarIfPresent(long userId, String avatarUrl) {
        if (!StringUtils.hasText(avatarUrl)) {
            return;
        }
        UserDomain avatarRow = userService.getById(userId);
        if (avatarRow == null) {
            return;
        }
        applyAvatarPatchToDomain(avatarRow, userId, avatarUrl);
        avatarRow.setUpdatedAt(LocalDateTime.now());
        avatarRow.setUpdatedBy(userId);
        userService.updateById(avatarRow);
    }

    /** 优先使用 GeoIP 坐标，缺失时回退到用户已存坐标。 */
    private static Double preferGeoOrStored(Double geoValue, Double storedValue) {
        if (geoValue != null) {
            return geoValue;
        }
        return storedValue;
    }

    /** 二次验证跳过风控门时返回无风险；否则按历史登录与坐标评估。 */
    private static LoginRiskEvaluator.RiskResult resolveLoginRisk(
            boolean skipRiskGate,
            GeoIpLookup geo,
            String deviceUuid,
            Double curLat,
            Double curLng,
            List<LoginDomain> prev,
            Double prevLat,
            Double prevLng) {
        if (skipRiskGate) {
            return new LoginRiskEvaluator.RiskResult(LoginRiskEvaluator.RISK_NONE, 0);
        }
        return LoginRiskEvaluator.evaluate(
                geo.countryCode(), deviceUuid, curLat, curLng, prev, prevLat, prevLng);
    }

    /** 空白国家码归一为 null，否则 trim。 */
    private static String normalizeOptionalCountryCode(String countryCode) {
        if (countryCode == null || countryCode.isBlank()) {
            return null;
        }
        return countryCode.trim();
    }

    /** 资料补丁：昵称非空校验后写入。 */
    private void applyNicknamePatch(UserDomain row, String nickname) {
        String n = nickname.trim();
        if (n.isEmpty()) {
            throw new BadRequestException(appMessages.get("app.error.profile.nicknameRequired"));
        }
        row.setNickname(n);
    }

    /** 从 Google 邮箱本地部分推导默认昵称，无邮箱则为 User。 */
    private static String resolveGoogleNickname(VerifiedGoogleIdentity google) {
        if (!StringUtils.hasText(google.email())) {
            return "User";
        }
        int at = google.email().indexOf('@');
        if (at > 0) {
            return google.email().substring(0, at);
        }
        return google.email();
    }

    private void recordLogin(Long userId, String deviceUuid, int result, String failReason, int riskLevel) {
        recordLogin(userId, deviceUuid, result, failReason, riskLevel, null);
    }

    private void recordLogin(
            Long userId, String deviceUuid, int result, String failReason, int riskLevel, String ipCountry) {
        try {
            String ip = MyRequestContextHolder.ipAddress();
            GeoIpLookup geo = geoIpService.resolve(ip);
            LoginDomain row = new LoginDomain();
            row.setUserId(userId);
            row.setLoginIp(ip);
            row.setDeviceUuid(StringUtils.hasText(deviceUuid) ? deviceUuid.trim() : null);
            row.setLoginResult(result);
            row.setFailReason(failReason);
            row.setUserAgent(resolveUserAgent());
            row.setIpCountry(StringUtils.hasText(ipCountry) ? ipCountry : geo.countryCode());
            row.setRiskLevel(riskLevel);
            LocalDateTime now = LocalDateTime.now();
            row.setCreatedAt(now);
            row.setUpdatedAt(now);
            row.setDelFlag(false);
            loginService.save(row);
        } catch (Exception e) {
            log.warn("record login failed: {}", e.toString());
        }
    }

    private static String resolveUserAgent() {
        RequestContext ctx = MyRequestContextHolder.getContext();
        if (ctx == null) {
            return null;
        }
        try {
            Object headers = ctx.getClass().getMethod("getHeaders").invoke(ctx);
            return extractUserAgentFromHeaders(headers);
        } catch (ReflectiveOperationException ignored) {
            // framework may not expose headers map
        }
        return null;
    }

    /** 从请求头 Map 中读取 User-Agent（兼容大小写键名）。 */
    private static String extractUserAgentFromHeaders(Object headers) {
        if (!(headers instanceof java.util.Map<?, ?> map)) {
            return null;
        }
        Object ua = map.get("User-Agent");
        if (ua == null) {
            ua = map.get("user-agent");
        }
        return ua != null ? ua.toString() : null;
    }

    private static String resolveClientLanguageTag() {
        Locale loc = LocaleContextHolder.getLocale();
        return loc != null ? loc.toLanguageTag() : "en";
    }

    /** 注册时用 IP 定位补全国家/城市/坐标（用户已选手动国家则保留）。 */
    private void applyGeoToUser(UserDomain user, GeoIpLookup geo, boolean fillCountryIfBlank) {
        if (geo == null) {
            return;
        }
        if (fillCountryIfBlank && !StringUtils.hasText(user.getCountryCode()) && geo.hasCountry()) {
            user.setCountryCode(geo.countryCode());
        }
        if (!StringUtils.hasText(user.getCity()) && StringUtils.hasText(geo.city())) {
            user.setCity(geo.city());
        }
        if (user.getLatitude() == null && geo.latitude() != null) {
            user.setLatitude(geo.latitude());
        }
        if (user.getLongitude() == null && geo.longitude() != null) {
            user.setLongitude(geo.longitude());
        }
    }

    private void applyGeoUpdateIfEmpty(long userId, GeoIpLookup geo) {
        if (geo == null || (!geo.hasCountry() && geo.latitude() == null)) {
            return;
        }
        UserDomain u = userService.getById(userId);
        if (u == null) {
            return;
        }
        boolean changed = false;
        if (!StringUtils.hasText(u.getCountryCode()) && geo.hasCountry()) {
            u.setCountryCode(geo.countryCode());
            changed = true;
        }
        if (!StringUtils.hasText(u.getCity()) && StringUtils.hasText(geo.city())) {
            u.setCity(geo.city());
            changed = true;
        }
        if (u.getLatitude() == null && geo.latitude() != null) {
            u.setLatitude(geo.latitude());
            changed = true;
        }
        if (u.getLongitude() == null && geo.longitude() != null) {
            u.setLongitude(geo.longitude());
            changed = true;
        }
        if (changed) {
            u.setUpdatedAt(LocalDateTime.now());
            u.setUpdatedBy(userId);
            userService.updateById(u);
        }
    }

    private void finalizeAccountDeletionIfCooldownElapsed(Long userId) {
        UserDomain u = userService.getById(userId);
        if (u == null || Boolean.TRUE.equals(u.isDelFlag())) {
            return;
        }
        LocalDateTime req = u.getDeletionRequestedAt();
        if (req == null) {
            return;
        }
        if (LocalDateTime.now().isBefore(req.plusDays(ACCOUNT_DELETION_COOLDOWN_DAYS))) {
            return;
        }
        LocalDateTime now = LocalDateTime.now();
        friendshipService.deactivateAllFriendshipsForUser(userId);
        userIdentityService.releaseAllForUser(userId, now);
        userService.finalizeDeletion(userId);
    }

    private String assertDeviceUuidMatchesHeaderOrBody(String bodyDeviceUuid) {
        String uuid = bodyDeviceUuid.trim();
        RequestContext ctx = MyRequestContextHolder.getContext();
        if (ctx == null) {
            return uuid;
        }
        String headerEq = ctx.getEquipmentId();
        if (!StringUtils.hasText(headerEq)) {
            return uuid;
        }
        if (!headerEq.trim().equals(uuid)) {
            throw new BadRequestException(appMessages.get("app.error.device.headerBodyMismatch"));
        }
        return uuid;
    }

    private static String normalizeDeviceType(String raw) {
        if (raw == null) {
            return "";
        }
        String t = raw.trim().toLowerCase();
        if (t.isEmpty()) {
            return "";
        }
        if (t.equals("ios") || t.equals("iphone") || t.equals("ipad")) {
            return "ios";
        }
        if (t.equals("android")) {
            return "android";
        }
        return t;
    }

    private void touchDevice(long userId, String deviceUuid, String deviceType) {
        String uuid = deviceUuid.trim();
        UserDeviceDomain existing = userDeviceService.findActiveByUserIdAndDeviceUuid(userId, uuid);
        LocalDateTime now = LocalDateTime.now();
        if (existing != null) {
            existing.setLastLoginAt(now);
            existing.setDeviceType(deviceType);
            existing.setUpdatedAt(now);
            existing.setUpdatedBy(userId);
            userDeviceService.updateById(existing);
            return;
        }
        UserDeviceDomain d = new UserDeviceDomain();
        d.initAudit(userId);
        d.setUserId(userId);
        d.setDeviceUuid(uuid);
        d.setDeviceType(deviceType);
        d.setLastLoginAt(now);
        d.setStatus(1);
        userDeviceService.save(d);
    }

    private AppPublicUserVO toPublic(UserDTO dto, Long viewerUserId, boolean includeEmail) {
        if (dto == null) {
            return null;
        }
        boolean self = viewerUserId != null && Objects.equals(viewerUserId, dto.getId());
        String storedRef = self
                ? UserAvatarAuditSupport.ownerVisibleStoredRef(dto)
                : UserAvatarAuditSupport.publicStoredRef(dto);
        String av = storedRef;
        if (viewerUserId != null && StringUtils.hasText(av)) {
            av = ossDisplayUrlService.signAvatarForViewer(viewerUserId, av.trim());
        }
        AppPublicUserVO.AppPublicUserVOBuilder b = AppPublicUserVO.builder()
                .id(dto.getId())
                .nickname(dto.getNickname())
                .gender(dto.getGender())
                .birthYear(dto.getBirthYear())
                .countryCode(dto.getCountryCode())
                .city(dto.getCity())
                .latitude(dto.getLatitude())
                .longitude(dto.getLongitude())
                .language(dto.getLanguage())
                .writingStyle(dto.getWritingStyle())
                .emailVerified(Boolean.TRUE.equals(dto.getEmailVerified()))
                .bio(dto.getBio())
                .avatarUrl(av)
                .isVip(dto.getIsVip());
        if (includeEmail && self) {
            b.email(dto.getEmail());
        }
        AppPublicUserVO vo = b.build();
        if (self && UserAvatarAuditSupport.hasStoredAvatar(dto)) {
            vo.setAvatarAuditStatus(UserAvatarAuditSupport.statusOf(dto));
        }
        LocalDateTime reqAt = dto.getDeletionRequestedAt();
        if (reqAt != null) {
            vo.setDeletionRequestedAt(reqAt);
            vo.setDeletionEffectiveAt(reqAt.plusDays(ACCOUNT_DELETION_COOLDOWN_DAYS));
        }
        UserInterestAssembler.Payload interests = userInterestAssembler.loadForUser(dto.getId());
        vo.setInterestTagIds(interests.ids());
        vo.setInterestTagNames(interests.names());
        return vo;
    }

    private void assertGenderValid(Integer gender) {
        if (gender == null || !UserGender.isValidForProfile(gender)) {
            throw new BadRequestException(appMessages.get("app.error.profile.genderRequired"));
        }
    }

    private void applyAvatarPatchToDomain(UserDomain row, long uid, String rawAvatar) {
        String raw = rawAvatar.trim();
        if (raw.isEmpty()) {
            row.setAvatarUrl(null);
            row.setAvatarAuditStatus(UserAvatarAuditSupport.PENDING);
            return;
        }
        String normalized =
                OssReadableKeyValidator.normalizeAndValidate(ossProperties.getKeyPrefix(), raw, appMessages);
        OssReadableKeyValidator.ParsedOssKey p =
                OssReadableKeyValidator.parseNormalizedKey(ossProperties.getKeyPrefix(), normalized, appMessages);
        if (!"avatar".equals(p.sceneLower()) || p.ownerUserId() != uid) {
            throw new BadRequestException(appMessages.get("app.error.profile.avatarInvalid"));
        }
        row.setAvatarUrl(normalized);
        row.setAvatarAuditStatus(UserAvatarAuditSupport.PENDING);
    }

    private static Integer convertStatus(Object status) {
        if (status instanceof Number n) {
            return n.intValue();
        }
        if (status instanceof String s) {
            return Integer.valueOf(s);
        }
        return null;
    }

    private void assertInterestTagIdsValidForReplace(List<Integer> ids) {
        if (ids == null || ids.isEmpty()) {
            throw new BadRequestException(appMessages.get("app.error.tag.invalid"));
        }
        Set<Integer> unique = new LinkedHashSet<>(ids);
        if (unique.size() != ids.size()) {
            throw new BadRequestException(appMessages.get("app.error.tag.duplicate"));
        }
        for (Integer tid : unique) {
            TagDomain t = tagService.getById(tid);
            if (t == null || t.isDelFlag()) {
                throw new BadRequestException(appMessages.get("app.error.tag.invalid"));
            }
        }
    }
}
