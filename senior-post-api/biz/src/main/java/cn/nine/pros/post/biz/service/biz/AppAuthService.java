package cn.nine.pros.post.biz.service.biz;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.context.RequestContext;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.config.OssProperties;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.model.domain.TagDomain;
import cn.nine.pros.post.biz.model.domain.UserDeviceDomain;
import cn.nine.pros.post.biz.model.domain.UserDomain;
import cn.nine.pros.post.biz.model.domain.UserIdentityDomain;
import cn.nine.pros.post.biz.service.biz.support.AppAuthProfileSupport;
import cn.nine.pros.post.biz.service.biz.support.GoogleIdTokenVerifierService;
import cn.nine.pros.post.biz.service.biz.support.GoogleIdTokenVerifierService.VerifiedGoogleIdentity;
import cn.nine.pros.post.biz.service.biz.support.OssReadableKeyValidator;
import cn.nine.pros.post.biz.service.biz.support.UserAvatarAuditSupport;
import cn.nine.pros.post.biz.service.biz.support.UserInterestAssembler;
import cn.nine.pros.post.biz.service.base.FriendshipService;
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
import cn.nine.pros.post.client.model.input.AppLoginInDto;
import cn.nine.pros.post.client.model.input.AppRegisterInDto;
import cn.nine.pros.post.client.model.input.AppResetPasswordInDto;
import cn.nine.pros.post.client.model.out.AppAuthResultVO;
import cn.nine.pros.post.client.model.out.AppPublicUserVO;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.time.Year;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Objects;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class AppAuthService {

    private static final int MIN_AGE = 45;
    private static final int ACCOUNT_DELETION_COOLDOWN_DAYS = 7;

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
        user.setDelFlag(false);
        LocalDateTime now = LocalDateTime.now();
        user.setCreatedAt(now);
        user.setUpdatedAt(now);
        user.setCreatedBy(0L);
        user.setUpdatedBy(0L);
        user.setLastLoginAt(now);
        user.setRegisterIp(MyRequestContextHolder.ipAddress());
        userService.save(user);
        if (StringUtils.hasText(body.getAvatarUrl())) {
            LambdaUpdateWrapper<UserDomain> avUw =
                    new LambdaUpdateWrapper<UserDomain>().eq(UserDomain::getId, user.getId());
            applyAvatarPatchToWrapper(avUw, user.getId(), body.getAvatarUrl());
            userService.update(avUw);
        }

        userIdentityService.createEmailIdentity(
                user.getId(), email, passwordEncoder.encode(body.getPassword()), user.getId());

        userTagService.replaceUserTags(user.getId(), user.getId(), new ArrayList<>(new LinkedHashSet<>(regTagIds)));
        String deviceUuid = assertDeviceUuidMatchesHeaderOrBody(body.getDeviceUuid());
        touchDevice(user.getId(), deviceUuid, normalizeDeviceType(body.getDeviceType()));

        return finishAuth(user.getId(), true);
    }

    @Transactional(rollbackFor = Exception.class)
    public AppAuthResultVO login(AppLoginInDto body) {
        String email = body.getEmail().trim().toLowerCase();
        UserIdentityDomain ident = userIdentityService.findActiveEmailByUid(email);
        if (ident == null || !StringUtils.hasText(ident.getPasswordHash())) {
            throw new BadRequestException(appMessages.get("app.error.login.badCredential"));
        }
        if (!passwordEncoder.matches(body.getPassword(), ident.getPasswordHash())) {
            throw new BadRequestException(appMessages.get("app.error.login.badCredential"));
        }
        UserDTO dto = userService.findById(ident.getUserId());
        if (dto == null) {
            throw new BadRequestException(appMessages.get("app.error.login.badCredential"));
        }
        finalizeAccountDeletionIfCooldownElapsed(dto.getId());
        dto = userService.findById(dto.getId());
        if (dto == null) {
            throw new BadRequestException(appMessages.get("app.error.login.badCredential"));
        }
        if (dto.getStatus() == null || !Integer.valueOf(1).equals(convertStatus(dto.getStatus()))) {
            throw new BadRequestException(appMessages.get("app.error.account.unavailable"));
        }

        LocalDateTime now = LocalDateTime.now();
        userService.update(new LambdaUpdateWrapper<UserDomain>()
                .eq(UserDomain::getId, dto.getId())
                .set(UserDomain::getLastLoginAt, now)
                .set(UserDomain::getDeletionRequestedAt, null)
                .set(UserDomain::getUpdatedAt, now)
                .set(UserDomain::getUpdatedBy, dto.getId()));

        String deviceUuid = assertDeviceUuidMatchesHeaderOrBody(body.getDeviceUuid());
        touchDevice(dto.getId(), deviceUuid, normalizeDeviceType(body.getDeviceType()));

        UserInterestAssembler.Payload interests = userInterestAssembler.loadForUser(dto.getId());
        boolean complete = AppAuthProfileSupport.isProfileComplete(dto, interests.ids());
        return finishAuth(dto.getId(), complete);
    }

    public void validateRegisterEmail(String rawEmail) {
        String email = rawEmail.trim().toLowerCase();
        if (userIdentityService.findActiveEmailByUid(email) != null) {
            throw new BadRequestException(appMessages.get("app.error.register.emailTaken"));
        }
    }

    @Transactional(rollbackFor = Exception.class)
    public AppAuthResultVO loginWithGoogle(AppGoogleLoginInDto body) {
        VerifiedGoogleIdentity google = googleIdTokenVerifierService.verify(body.getIdToken());
        UserIdentityDomain existing = userIdentityService.findActiveByProviderUid(AuthProvider.GOOGLE, google.sub());
        long userId;
        if (existing != null) {
            userId = existing.getUserId();
        } else if (StringUtils.hasText(google.email())) {
            UserIdentityDomain emailIdent = userIdentityService.findActiveEmailByUid(google.email());
            if (emailIdent != null) {
                userId = emailIdent.getUserId();
                userIdentityService.createOAuthIdentity(userId, AuthProvider.GOOGLE, google.sub(), userId);
            } else {
                userId = createGoogleShellUser(google);
            }
        } else {
            userId = createGoogleShellUser(google);
        }

        finalizeAccountDeletionIfCooldownElapsed(userId);
        UserDTO dto = userService.findById(userId);
        if (dto == null || dto.getStatus() == null || !Integer.valueOf(1).equals(convertStatus(dto.getStatus()))) {
            throw new BadRequestException(appMessages.get("app.error.account.unavailable"));
        }

        LocalDateTime now = LocalDateTime.now();
        userService.update(new LambdaUpdateWrapper<UserDomain>()
                .eq(UserDomain::getId, userId)
                .set(UserDomain::getLastLoginAt, now)
                .set(UserDomain::getDeletionRequestedAt, null)
                .set(UserDomain::getUpdatedAt, now)
                .set(UserDomain::getUpdatedBy, userId));

        String deviceUuid = assertDeviceUuidMatchesHeaderOrBody(body.getDeviceUuid());
        touchDevice(userId, deviceUuid, normalizeDeviceType(body.getDeviceType()));

        UserInterestAssembler.Payload interests = userInterestAssembler.loadForUser(userId);
        boolean complete = AppAuthProfileSupport.isProfileComplete(dto, interests.ids());
        return finishAuth(userId, complete);
    }

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

        LambdaUpdateWrapper<UserDomain> uw = new LambdaUpdateWrapper<UserDomain>()
                .eq(UserDomain::getId, uid)
                .set(UserDomain::getGender, body.getGender())
                .set(UserDomain::getBirthYear, body.getBirthYear())
                .set(UserDomain::getNickname, body.getNickname().trim())
                .set(UserDomain::getCountryCode,
                        body.getCountryCode() != null && !body.getCountryCode().isBlank()
                                ? body.getCountryCode().trim()
                                : null)
                .set(UserDomain::getUpdatedAt, LocalDateTime.now())
                .set(UserDomain::getUpdatedBy, uid);
        if (body.getAvatarUrl() != null) {
            applyAvatarPatchToWrapper(uw, uid, body.getAvatarUrl());
        }
        userService.update(uw);
        userTagService.replaceUserTags(uid, uid, new ArrayList<>(new LinkedHashSet<>(body.getInterestTagIds())));

        return finishAuth(uid, true);
    }

    public void forgotPassword(AppForgotPasswordInDto body) {
        String email = body.getEmail().trim().toLowerCase();
        UserIdentityDomain ident = userIdentityService.findActiveEmailByUid(email);
        if (ident != null && userIdentityService.hasOAuthOnly(ident.getUserId())) {
            throw new BadRequestException(appMessages.get("app.error.password.oauthOnly"));
        }
        passwordResetService.requestForgotPassword(body.getEmail());
    }

    public void resetPassword(AppResetPasswordInDto body) {
        passwordResetService.completeReset(body.getEmail(), body.getCode(), body.getNewPassword());
    }

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
        LocalDateTime now = LocalDateTime.now();
        userService.update(new LambdaUpdateWrapper<UserDomain>()
                .eq(UserDomain::getId, uid)
                .eq(UserDomain::isDelFlag, false)
                .set(UserDomain::getDeletionRequestedAt, now)
                .set(UserDomain::getUpdatedAt, now)
                .set(UserDomain::getUpdatedBy, uid));
    }

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
        LambdaUpdateWrapper<UserDomain> uw =
                new LambdaUpdateWrapper<UserDomain>().eq(UserDomain::getId, uid);
        if (body.getGender() != null) {
            assertGenderValid(body.getGender());
            uw.set(UserDomain::getGender, body.getGender());
            changed = true;
            userRowChanged = true;
        }
        if (body.getNickname() != null) {
            String n = body.getNickname().trim();
            if (n.isEmpty()) {
                throw new BadRequestException(appMessages.get("app.error.profile.nicknameRequired"));
            }
            uw.set(UserDomain::getNickname, n);
            changed = true;
            userRowChanged = true;
        }
        if (body.getCountryCode() != null) {
            String c = body.getCountryCode().trim();
            uw.set(UserDomain::getCountryCode, c.isEmpty() ? null : c);
            changed = true;
            userRowChanged = true;
        }
        if (body.getBio() != null) {
            uw.set(UserDomain::getBio, body.getBio().trim());
            changed = true;
            userRowChanged = true;
        }
        if (body.getAvatarUrl() != null) {
            applyAvatarPatchToWrapper(uw, uid, body.getAvatarUrl());
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
            LocalDateTime now = LocalDateTime.now();
            uw.set(UserDomain::getUpdatedAt, now).set(UserDomain::getUpdatedBy, uid);
            userService.update(uw);
        }
        return toPublic(userService.findById(uid), uid, true);
    }

    private long createGoogleShellUser(VerifiedGoogleIdentity google) {
        String nick = "User";
        if (StringUtils.hasText(google.email())) {
            int at = google.email().indexOf('@');
            nick = at > 0 ? google.email().substring(0, at) : google.email();
        }
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

    private AppAuthResultVO finishAuth(long userId, boolean profileComplete) {
        String token = appJwtService.createToken(userId);
        UserDTO fresh = userService.findById(userId);
        return AppAuthResultVO.builder()
                .token(token)
                .user(toPublic(fresh, fresh.getId(), true))
                .profileComplete(profileComplete)
                .build();
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
        userService.update(new LambdaUpdateWrapper<UserDomain>()
                .eq(UserDomain::getId, userId)
                .eq(UserDomain::isDelFlag, false)
                .set(UserDomain::getStatus, 3)
                .set(UserDomain::getDeletionRequestedAt, null)
                .set(UserDomain::getUpdatedAt, now)
                .set(UserDomain::getUpdatedBy, userId));
    }

    private String assertDeviceUuidMatchesHeaderOrBody(String bodyDeviceUuid) {
        String uuid = bodyDeviceUuid.trim();
        RequestContext ctx = MyRequestContextHolder.getContext();
        if (ctx != null) {
            String headerEq = ctx.getEquipmentId();
            if (StringUtils.hasText(headerEq) && !headerEq.trim().equals(uuid)) {
                throw new BadRequestException(appMessages.get("app.error.device.headerBodyMismatch"));
            }
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
        UserDeviceDomain existing = userDeviceService.getOne(
                new LambdaQueryWrapper<UserDeviceDomain>()
                        .eq(UserDeviceDomain::getUserId, userId)
                        .eq(UserDeviceDomain::getDeviceUuid, uuid)
                        .eq(UserDeviceDomain::isDelFlag, false));
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

    private void applyAvatarPatchToWrapper(LambdaUpdateWrapper<UserDomain> uw, long uid, String rawAvatar) {
        String raw = rawAvatar.trim();
        if (raw.isEmpty()) {
            uw.set(UserDomain::getAvatarUrl, null);
            uw.set(UserDomain::getAvatarAuditStatus, UserAvatarAuditSupport.PENDING);
            return;
        }
        String normalized =
                OssReadableKeyValidator.normalizeAndValidate(ossProperties.getKeyPrefix(), raw, appMessages);
        OssReadableKeyValidator.ParsedOssKey p =
                OssReadableKeyValidator.parseNormalizedKey(ossProperties.getKeyPrefix(), normalized, appMessages);
        if (!"avatar".equals(p.sceneLower()) || p.ownerUserId() != uid) {
            throw new BadRequestException(appMessages.get("app.error.profile.avatarInvalid"));
        }
        uw.set(UserDomain::getAvatarUrl, normalized);
        uw.set(UserDomain::getAvatarAuditStatus, UserAvatarAuditSupport.PENDING);
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
