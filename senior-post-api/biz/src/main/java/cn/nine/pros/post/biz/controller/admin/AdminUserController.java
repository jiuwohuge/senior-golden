package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.config.OssProperties;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.model.domain.UserDeviceDomain;
import cn.nine.pros.post.biz.model.domain.UserDomain;
import cn.nine.pros.post.biz.model.mapstruct.UserDeviceMapstruct;
import cn.nine.pros.post.biz.model.mapstruct.UserMapstruct;
import cn.nine.pros.post.biz.service.app.support.OssReadableKeyValidator;
import cn.nine.pros.post.biz.service.app.support.UserAvatarAuditSupport;
import cn.nine.pros.post.biz.service.base.UserDeviceService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.biz.service.base.support.DeletedUserEmailSupport;
import cn.nine.pros.post.client.api.admin.AdminUserApi;
import cn.nine.pros.post.client.model.db.UserDTO;
import cn.nine.pros.post.client.model.db.UserDeviceDTO;
import cn.nine.pros.post.client.model.input.admin.AdminUserSaveInDto;
import cn.nine.pros.post.client.model.input.admin.AdminUserVipDebugInDto;
import cn.nine.pros.post.client.model.input.admin.DeviceBlockInDto;
import cn.nine.pros.post.client.model.input.admin.UserQueryInDto;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.apache.commons.lang3.StringUtils;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequiredArgsConstructor
public class AdminUserController implements AdminUserApi {

    private static boolean canLoginConsole(UserDomain u) {
        return u != null && u.getStaffRole() != null && u.getStaffRole() != 0;
    }

    private static Long auditUserId() {
        return MyRequestContextHolder.userId();
    }

    private final UserService userService;
    private final UserMapstruct userMapstruct;
    private final UserDeviceService userDeviceService;
    private final UserDeviceMapstruct userDeviceMapstruct;
    private final AppMessages appMessages;
    private final OssProperties ossProperties;

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
        if (body.getAvatarAuditStatus() != null) {
            qw.eq(UserDomain::getAvatarAuditStatus, body.getAvatarAuditStatus());
        }
        Page<UserDomain> p = userService.page(AdminPageHelper.mpPage(pageQuery), qw);
        List<UserDTO> list = p.getRecords().stream().map(userMapstruct::toDTO).collect(Collectors.toList());
        return AdminPageHelper.pageData(pageQuery, p, list);
    }

    @Override
    public void updateStatus(Long id, Integer status) {
        if (status == null || (status != 1 && status != 2 && status != 3)) {
            throw new BadRequestException(appMessages.get("admin.error.user.badStatus"));
        }
        LocalDateTime now = LocalDateTime.now();
        LambdaUpdateWrapper<UserDomain> uw = new LambdaUpdateWrapper<UserDomain>()
                .eq(UserDomain::getId, id)
                .set(UserDomain::getStatus, status)
                .set(UserDomain::getUpdatedBy, auditUserId())
                .set(UserDomain::getUpdatedAt, now);
        if (status == 3) {
            UserDomain user = userService.getById(id);
            if (user != null && StringUtils.isNotBlank(user.getEmail())) {
                uw.set(UserDomain::getEmail, DeletedUserEmailSupport.archive(user.getEmail(), now));
            }
        }
        userService.update(uw);
    }

    @Override
    public void save(AdminUserSaveInDto body) {
        Long id = body.getId();
        if (id == null) {
            throw new BadRequestException(appMessages.get("admin.error.user.badId"));
        }
        UserDomain user = userService.getById(id);
        if (user == null || user.isDelFlag()) {
            throw new BadRequestException(appMessages.get("admin.error.user.notFound"));
        }
        Integer status = body.getStatus();
        if (status != null && status != 1 && status != 2 && status != 3) {
            throw new BadRequestException(appMessages.get("admin.error.user.badStatus"));
        }
        String nickname = trimToNull(body.getNickname());
        String countryCode = trimToNull(body.getCountryCode());
        String bio = trimToNull(body.getBio());
        Integer birthYear = body.getBirthYear();
        boolean avatarTouched = body.getAvatarUrl() != null;
        boolean hasEditable = status != null
                || birthYear != null
                || nickname != null
                || countryCode != null
                || bio != null
                || avatarTouched;
        if (!hasEditable) {
            throw new BadRequestException(appMessages.get("admin.error.user.emptyUpdate"));
        }
        LambdaUpdateWrapper<UserDomain> uw = new LambdaUpdateWrapper<UserDomain>()
                .eq(UserDomain::getId, id)
                .set(status != null, UserDomain::getStatus, status)
                .set(birthYear != null, UserDomain::getBirthYear, birthYear)
                .set(nickname != null, UserDomain::getNickname, nickname)
                .set(countryCode != null, UserDomain::getCountryCode, countryCode)
                .set(bio != null, UserDomain::getBio, bio)
                .set(UserDomain::getUpdatedBy, auditUserId())
                .set(UserDomain::getUpdatedAt, LocalDateTime.now());
        if (avatarTouched) {
            applyAdminAvatarUpdate(uw, id, body.getAvatarUrl());
        }
        userService.update(uw);
    }

    private void applyAdminAvatarUpdate(LambdaUpdateWrapper<UserDomain> uw, long userId, String rawAvatar) {
        String raw = rawAvatar == null ? "" : rawAvatar.trim();
        if (raw.isEmpty()) {
            uw.set(UserDomain::getAvatarUrl, null);
            uw.set(UserDomain::getAvatarAuditStatus, UserAvatarAuditSupport.PENDING);
            return;
        }
        String normalized =
                OssReadableKeyValidator.normalizeAndValidate(ossProperties.getKeyPrefix(), raw, appMessages);
        OssReadableKeyValidator.ParsedOssKey p =
                OssReadableKeyValidator.parseNormalizedKey(ossProperties.getKeyPrefix(), normalized, appMessages);
        if (!"avatar".equals(p.sceneLower()) || p.ownerUserId() != userId) {
            throw new BadRequestException(appMessages.get("admin.error.user.avatarInvalid"));
        }
        uw.set(UserDomain::getAvatarUrl, normalized);
        uw.set(UserDomain::getAvatarAuditStatus, UserAvatarAuditSupport.APPROVED);
    }

    @Override
    public void delete(Long id) {
        if (id == null) {
            throw new BadRequestException(appMessages.get("admin.error.user.badId"));
        }
        UserDomain user = userService.getById(id);
        if (user != null && canLoginConsole(user)) {
            throw new BadRequestException(appMessages.get("admin.error.user.cannotDeleteStaff"));
        }
        userService.delByIds(List.of(id));
    }

    @Override
    public void approveAvatar(Long id) {
        updateAvatarAudit(id, UserAvatarAuditSupport.APPROVED);
    }

    @Override
    public void rejectAvatar(Long id) {
        updateAvatarAudit(id, UserAvatarAuditSupport.REJECTED);
    }

    private void updateAvatarAudit(Long id, int targetStatus) {
        if (id == null) {
            throw new BadRequestException(appMessages.get("admin.error.user.badId"));
        }
        UserDomain user = userService.getById(id);
        if (user == null || user.isDelFlag()) {
            throw new BadRequestException(appMessages.get("admin.error.user.notFound"));
        }
        if (!UserAvatarAuditSupport.hasStoredAvatar(user)) {
            throw new BadRequestException(appMessages.get("admin.error.user.avatarNotFound"));
        }
        int current = UserAvatarAuditSupport.statusOf(user);
        if (current == targetStatus) {
            return;
        }
        userService.update(new LambdaUpdateWrapper<UserDomain>()
                .eq(UserDomain::getId, id)
                .set(UserDomain::getAvatarAuditStatus, targetStatus)
                .set(UserDomain::getUpdatedBy, auditUserId())
                .set(UserDomain::getUpdatedAt, LocalDateTime.now()));
    }

    @Override
    public void updateVipDebug(Long id, AdminUserVipDebugInDto body) {
        if (id == null) {
            throw new BadRequestException(appMessages.get("admin.error.user.badId"));
        }
        UserDomain u = userService.getById(id);
        if (u == null || u.isDelFlag()) {
            throw new BadRequestException(appMessages.get("admin.error.user.notFound"));
        }
        if (u.getStaffRole() != null && u.getStaffRole() != 0) {
            throw new BadRequestException(appMessages.get("admin.error.user.cannotEditStaffVip"));
        }
        LocalDateTime now = LocalDateTime.now();
        LambdaUpdateWrapper<UserDomain> uw = new LambdaUpdateWrapper<UserDomain>()
                .eq(UserDomain::getId, id)
                .set(UserDomain::getIsVip, Boolean.TRUE.equals(body.getIsVip()))
                .set(UserDomain::getUpdatedAt, now)
                .set(UserDomain::getUpdatedBy, auditUserId());
        if (Boolean.TRUE.equals(body.getClearVipExpireAt())) {
            uw.set(UserDomain::getVipExpireAt, null);
        } else if (body.getVipExpireAt() != null) {
            uw.set(UserDomain::getVipExpireAt, body.getVipExpireAt());
        }
        userService.update(uw);
    }

    @Override
    public void blockDevice(DeviceBlockInDto body) {
        userDeviceService.update(new LambdaUpdateWrapper<UserDeviceDomain>()
                .eq(UserDeviceDomain::getDeviceUuid, body.getDeviceUuid())
                .eq(UserDeviceDomain::isDelFlag, false)
                .set(UserDeviceDomain::getStatus, 2)
                .set(UserDeviceDomain::getUpdatedBy, auditUserId())
                .set(UserDeviceDomain::getUpdatedAt, java.time.LocalDateTime.now()));
    }

    @Override
    public List<UserDeviceDTO> listUserDevices(Long userId) {
        if (userId == null) {
            throw new BadRequestException(appMessages.get("admin.error.user.badId"));
        }
        List<UserDeviceDomain> list = userDeviceService.list(
                new LambdaQueryWrapper<UserDeviceDomain>()
                        .eq(UserDeviceDomain::getUserId, userId)
                        .eq(UserDeviceDomain::isDelFlag, false)
                        .orderByDesc(UserDeviceDomain::getUpdatedAt));
        return list.stream().map(userDeviceMapstruct::toDTO).collect(Collectors.toList());
    }

    @Override
    public UserDTO currentAdmin() {
        Long uid = MyRequestContextHolder.userId();
        if (uid == null) {
            return null;
        }
        UserDomain d = userService.getById(uid);
        if (d == null || !canLoginConsole(d)) {
            return null;
        }
        UserDTO dto = userMapstruct.toDTO(d);
        if (dto != null) {
            dto.setPasswordHash(null);
        }
        return dto;
    }

    private static String trimToNull(String raw) {
        if (raw == null) {
            return null;
        }
        String value = raw.trim();
        return value.isEmpty() ? null : value;
    }
}
