package cn.nine.pros.post.biz.service.app;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.model.domain.UserDeviceDomain;
import cn.nine.pros.post.biz.model.domain.UserDomain;
import cn.nine.pros.post.biz.service.base.UserDeviceService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.client.model.db.UserDTO;
import cn.nine.pros.post.client.model.input.AppLoginInDto;
import cn.nine.pros.post.client.model.input.AppRegisterInDto;
import cn.nine.pros.post.client.model.out.AppAuthResultVO;
import cn.nine.pros.post.client.model.out.AppPublicUserVO;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.Year;

@Service
@RequiredArgsConstructor
public class AppAuthService {

    /** M1 默认最低年龄；后续改为读取 sys_config。 */
    private static final int MIN_AGE = 45;

    private final UserService userService;
    private final UserDeviceService userDeviceService;
    private final PasswordEncoder passwordEncoder;
    private final AppJwtService appJwtService;

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
        user.setDelFlag(false);
        LocalDateTime now = LocalDateTime.now();
        user.setCreatedAt(now);
        user.setUpdatedAt(now);
        user.setCreatedBy("0");
        user.setUpdatedBy("0");
        user.setLastLoginAt(now);
        user.setRegisterIp(MyRequestContextHolder.ipAddress());
        userService.save(user);
        touchDevice(user.getId(), body.getDeviceUuid(), body.getDeviceType());

        String token = appJwtService.createToken(user.getId());
        return AppAuthResultVO.builder()
                .token(token)
                .user(toPublic(userService.findById(user.getId())))
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
        UserDTO fresh = userService.findById(dto.getId());
        return AppAuthResultVO.builder()
                .token(token)
                .user(toPublic(fresh))
                .build();
    }

    public AppPublicUserVO me() {
        Long uid = MyRequestContextHolder.userIdNum();
        if (uid == null) {
            return null;
        }
        UserDTO dto = userService.findById(uid);
        if (dto == null) {
            return null;
        }
        return toPublic(dto);
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
            existing.setUpdatedBy(String.valueOf(userId));
            userDeviceService.updateById(existing);
            return;
        }
        UserDeviceDomain d = new UserDeviceDomain();
        d.setUserId(userId);
        d.setDeviceUuid(uuid);
        d.setDeviceType(deviceType);
        d.setLastLoginAt(now);
        d.setStatus(1);
        d.setDelFlag(false);
        d.setCreatedAt(now);
        d.setUpdatedAt(now);
        d.setCreatedBy(String.valueOf(userId));
        d.setUpdatedBy(String.valueOf(userId));
        userDeviceService.save(d);
    }

    private static AppPublicUserVO toPublic(UserDTO dto) {
        if (dto == null) {
            return null;
        }
        return AppPublicUserVO.builder()
                .id(dto.getId())
                .email(dto.getEmail())
                .nickname(dto.getNickname())
                .birthYear(dto.getBirthYear())
                .countryCode(dto.getCountryCode())
                .bio(dto.getBio())
                .avatarUrl(dto.getAvatarUrl())
                .stampsBalance(dto.getStampsBalance())
                .isVip(dto.getIsVip())
                .build();
    }
}
