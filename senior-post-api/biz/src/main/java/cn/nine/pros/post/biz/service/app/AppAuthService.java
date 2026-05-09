package cn.nine.pros.post.biz.service.app;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.config.OssProperties;
import cn.nine.pros.post.biz.model.domain.TagDomain;
import cn.nine.pros.post.biz.model.domain.UserDeviceDomain;
import cn.nine.pros.post.biz.model.domain.UserDomain;
import cn.nine.pros.post.biz.service.app.support.OssReadableKeyValidator;
import cn.nine.pros.post.biz.service.app.support.UserInterestAssembler;
import cn.nine.pros.post.biz.service.base.OssDisplayUrlService;
import cn.nine.pros.post.biz.service.base.TagService;
import cn.nine.pros.post.biz.service.base.UserDeviceService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.biz.service.base.UserTagService;
import cn.nine.pros.post.client.model.db.UserDTO;
import cn.nine.pros.post.client.model.input.AppAuthProfilePatchInDto;
import cn.nine.pros.post.client.model.input.AppForgotPasswordInDto;
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
import java.util.Set;

@Service
@RequiredArgsConstructor
public class AppAuthService {

    /**
     * M1 默认最低年龄；后续改为读取 sys_config。
     */
    private static final int MIN_AGE = 45;

    private final UserService userService;
    private final UserDeviceService userDeviceService;
    private final PasswordEncoder passwordEncoder;
    private final AppJwtService appJwtService;
    private final OssDisplayUrlService ossDisplayUrlService;
    private final PasswordResetService passwordResetService;
    private final OssProperties ossProperties;
    private final UserTagService userTagService;
    private final TagService tagService;
    private final UserInterestAssembler userInterestAssembler;
    private final cn.nine.pros.post.biz.service.base.StampGrantService stampGrantService;

    @Transactional(rollbackFor = Exception.class)
    public AppAuthResultVO register(AppRegisterInDto body) {
        String email = body.getEmail().trim().toLowerCase();
        if (userService.findByEmail(email) != null) {
            throw new BadRequestException("该邮箱已注册");
        }
        int currentYear = Year.now().getValue();
        int age = currentYear - body.getBirthYear();
        if (age < MIN_AGE) {
            throw new BadRequestException("注册年龄需满 " + MIN_AGE + " 岁");
        }
        List<Integer> regTagIds = body.getInterestTagIds();
        assertInterestTagIdsValidForReplace(regTagIds);

        UserDomain user = new UserDomain();
        user.setEmail(email);
        user.setPasswordHash(passwordEncoder.encode(body.getPassword()));
        user.setNickname(body.getNickname().trim());
        user.setBirthYear(body.getBirthYear());
        user.setCountryCode(body.getCountryCode() != null ? body.getCountryCode().trim() : null);
        user.setBio(null);
        user.setAvatarUrl(null);
        user.setStampsBalance(0);
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
        userTagService.replaceUserTags(user.getId(), user.getId(), new ArrayList<>(new LinkedHashSet<>(regTagIds)));
        touchDevice(user.getId(), body.getDeviceUuid(), body.getDeviceType());

        String token = appJwtService.createToken(user.getId());
        stampGrantService.afterLogin(user.getId());
        UserDTO regFresh = userService.findById(user.getId());
        return AppAuthResultVO.builder()
                .token(token)
                .user(toPublic(regFresh, regFresh.getId()))
                .build();
    }

    @Transactional(rollbackFor = Exception.class)
    public AppAuthResultVO login(AppLoginInDto body) {
        String email = body.getEmail().trim().toLowerCase();
        UserDTO dto = userService.findByEmail(email);
        if (dto == null) {
            throw new BadRequestException("邮箱或密码错误");
        }
        if (!passwordEncoder.matches(body.getPassword(), dto.getPasswordHash())) {
            throw new BadRequestException("邮箱或密码错误");
        }
        if (dto.getStatus() == null || !Integer.valueOf(1).equals(convertStatus(dto.getStatus()))) {
            throw new BadRequestException("账号不可用");
        }

        userService.update(new LambdaUpdateWrapper<UserDomain>()
                .eq(UserDomain::getId, dto.getId())
                .set(UserDomain::getLastLoginAt, LocalDateTime.now()));

        touchDevice(dto.getId(), body.getDeviceUuid(), body.getDeviceType());

        String token = appJwtService.createToken(dto.getId());
        stampGrantService.afterLogin(dto.getId());
        UserDTO fresh = userService.findById(dto.getId());
        return AppAuthResultVO.builder()
                .token(token)
                .user(toPublic(fresh, fresh.getId()))
                .build();
    }

    public void forgotPassword(AppForgotPasswordInDto body) {
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
        UserDTO dto = userService.findById(uid);
        if (dto == null) {
            return null;
        }
        return toPublic(dto, dto.getId());
    }

    @Transactional(rollbackFor = Exception.class)
    public AppPublicUserVO updateProfile(AppAuthProfilePatchInDto body) {
        Long uid = MyRequestContextHolder.userId();
        if (uid == null) {
            throw new BadRequestException("未登录或登录已失效");
        }
        UserDTO existing = userService.findById(uid);
        if (existing == null) {
            throw new BadRequestException("用户不存在");
        }
        boolean changed = false;
        boolean userRowChanged = false;
        LambdaUpdateWrapper<UserDomain> uw =
                new LambdaUpdateWrapper<UserDomain>().eq(UserDomain::getId, uid);
        if (body.getNickname() != null) {
            String n = body.getNickname().trim();
            if (n.isEmpty()) {
                throw new BadRequestException("昵称不能为空");
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
            String raw = body.getAvatarUrl().trim();
            if (raw.isEmpty()) {
                uw.set(UserDomain::getAvatarUrl, null);
            } else {
                String normalized =
                        OssReadableKeyValidator.normalizeAndValidate(ossProperties.getKeyPrefix(), raw);
                OssReadableKeyValidator.ParsedOssKey p =
                        OssReadableKeyValidator.parseNormalizedKey(ossProperties.getKeyPrefix(), normalized);
                if (!"avatar".equals(p.sceneLower()) || p.ownerUserId() != uid) {
                    throw new BadRequestException("头像路径无效或不属于当前用户");
                }
                uw.set(UserDomain::getAvatarUrl, normalized);
            }
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
            throw new BadRequestException("请至少提交一项可更新字段");
        }
        if (userRowChanged) {
            LocalDateTime now = LocalDateTime.now();
            uw.set(UserDomain::getUpdatedAt, now).set(UserDomain::getUpdatedBy, uid);
            userService.update(uw);
        }
        return toPublic(userService.findById(uid), uid);
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

    private AppPublicUserVO toPublic(UserDTO dto, Long viewerUserId) {
        if (dto == null) {
            return null;
        }
        String av = dto.getAvatarUrl();
        if (viewerUserId != null && StringUtils.hasText(av)) {
            av = ossDisplayUrlService.signAvatarForViewer(viewerUserId, av.trim());
        }
        AppPublicUserVO vo = AppPublicUserVO.builder()
                .id(dto.getId())
                .email(dto.getEmail())
                .nickname(dto.getNickname())
                .birthYear(dto.getBirthYear())
                .countryCode(dto.getCountryCode())
                .bio(dto.getBio())
                .avatarUrl(av)
                .stampsBalance(dto.getStampsBalance())
                .isVip(dto.getIsVip())
                .build();
        UserInterestAssembler.Payload interests = userInterestAssembler.loadForUser(dto.getId());
        vo.setInterestTagIds(interests.ids());
        vo.setInterestTagNames(interests.names());
        return vo;
    }

    private void assertInterestTagIdsValidForReplace(List<Integer> ids) {
        if (ids == null || ids.isEmpty()) {
            throw new BadRequestException("兴趣标签无效");
        }
        Set<Integer> unique = new LinkedHashSet<>(ids);
        if (unique.size() != ids.size()) {
            throw new BadRequestException("兴趣标签不可重复");
        }
        for (Integer tid : unique) {
            TagDomain t = tagService.getById(tid);
            if (t == null || t.isDelFlag()) {
                throw new BadRequestException("兴趣标签无效");
            }
        }
    }
}
