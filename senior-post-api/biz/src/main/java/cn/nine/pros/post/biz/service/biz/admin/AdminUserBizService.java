package cn.nine.pros.post.biz.service.biz.admin;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.config.OssProperties;
import cn.nine.pros.post.biz.controller.admin.AdminPageHelper;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.model.domain.UserDomain;
import cn.nine.pros.post.biz.model.mapstruct.UserDeviceMapstruct;
import cn.nine.pros.post.biz.model.mapstruct.UserMapstruct;
import cn.nine.pros.post.biz.service.base.UserDeviceService;
import cn.nine.pros.post.biz.service.base.UserIdentityService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.biz.service.biz.support.OssReadableKeyValidator;
import cn.nine.pros.post.biz.service.biz.support.UserAvatarAuditSupport;
import cn.nine.pros.post.client.model.db.UserDTO;
import cn.nine.pros.post.client.model.db.UserDeviceDTO;
import cn.nine.pros.post.client.model.input.admin.AdminUserSaveInDto;
import cn.nine.pros.post.client.model.input.admin.AdminUserVipDebugInDto;
import cn.nine.pros.post.client.model.input.admin.DeviceBlockInDto;
import cn.nine.pros.post.client.model.input.admin.UserQueryInDto;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 管理端用户运营：分页、状态、资料、头像审核、VIP 调试与设备封禁。
 */
@Service
@RequiredArgsConstructor
public class AdminUserBizService {

    private static boolean canLoginConsole(UserDomain u) {
        return u != null && u.getStaffRole() != null && u.getStaffRole() != 0;
    }

    private static Long auditUserId() {
        return MyRequestContextHolder.userId();
    }

    private final UserService userService;
    private final UserIdentityService userIdentityService;
    private final UserMapstruct userMapstruct;
    private final UserDeviceService userDeviceService;
    private final UserDeviceMapstruct userDeviceMapstruct;
    private final AppMessages appMessages;
    private final OssProperties ossProperties;

    /**
     * 按邮箱/昵称/状态/头像审核状态分页查询用户。
     */
    public PageData<UserDTO> paging(UserQueryInDto body) {
        PageQuery pageQuery = AdminPageHelper.normalize(body.getPage());
        Page<UserDomain> p = userService.pageForAdmin(
                pageQuery, body.getEmail(), body.getNickname(), body.getStatus(), body.getAvatarAuditStatus());
        List<UserDTO> list = p.getRecords().stream()
                .map(u -> userService.findById(u.getId()))
                .filter(dto -> dto != null)
                .collect(Collectors.toList());
        return AdminPageHelper.pageData(pageQuery, p, list);
    }

    /**
     * 更新用户状态；注销(3)时释放全部登录身份。
     */
    public void updateStatus(Long id, Integer status) {
        if (status == null || (status != 1 && status != 2 && status != 3)) {
            throw new BadRequestException(appMessages.get("admin.error.user.badStatus"));
        }
        if (status == 3) {
            userIdentityService.releaseAllForUser(id, LocalDateTime.now());
        }
        userService.adminUpdateStatus(id, status, auditUserId());
    }

    /**
     * 保存用户可编辑资料（状态/昵称/国家/简介/头像等）。
     */
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
        String avatarUrl = null;
        Integer avatarAuditStatus = null;
        if (avatarTouched) {
            AvatarUpdateFields avatar = resolveAvatarUpdate(id, body.getAvatarUrl());
            avatarUrl = avatar.url();
            avatarAuditStatus = avatar.auditStatus();
        }
        userService.adminUpdateProfile(
                id, status, birthYear, nickname, countryCode, bio, avatarUrl, avatarAuditStatus, auditUserId());
    }

    private record AvatarUpdateFields(String url, Integer auditStatus) {
    }

    /** 管理端头像：空串清空待审；非空须为该用户 avatar 场景 objectKey。 */
    private AvatarUpdateFields resolveAvatarUpdate(long userId, String avatarRaw) {
        String raw = avatarRaw == null ? "" : avatarRaw.trim();
        if (raw.isEmpty()) {
            return new AvatarUpdateFields(null, UserAvatarAuditSupport.PENDING);
        }
        String normalized =
                OssReadableKeyValidator.normalizeAndValidate(ossProperties.getKeyPrefix(), raw, appMessages);
        OssReadableKeyValidator.ParsedOssKey p =
                OssReadableKeyValidator.parseNormalizedKey(ossProperties.getKeyPrefix(), normalized, appMessages);
        if (!"avatar".equals(p.sceneLower()) || p.ownerUserId() != userId) {
            throw new BadRequestException(appMessages.get("admin.error.user.avatarInvalid"));
        }
        return new AvatarUpdateFields(normalized, UserAvatarAuditSupport.APPROVED);
    }

    /**
     * 软删除用户；禁止删除员工账号。
     */
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

    /**
     * 通过用户头像审核。
     */
    public void approveAvatar(Long id) {
        updateAvatarAudit(id, UserAvatarAuditSupport.APPROVED);
    }

    /**
     * 驳回用户头像审核。
     */
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
        userService.adminUpdateAvatarAudit(id, targetStatus, auditUserId());
    }

    /**
     * 调试设置用户 VIP 状态与过期时间（禁止改员工）。
     */
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
        userService.adminUpdateVipDebug(
                id,
                Boolean.TRUE.equals(body.getIsVip()),
                body.getVipExpireAt(),
                Boolean.TRUE.equals(body.getClearVipExpireAt()),
                auditUserId());
    }

    /**
     * 按设备 UUID 封禁设备。
     */
    public void blockDevice(DeviceBlockInDto body) {
        userDeviceService.blockByDeviceUuid(body.getDeviceUuid(), auditUserId());
    }

    /**
     * 列出用户活跃设备。
     */
    public List<UserDeviceDTO> listUserDevices(Long userId) {
        if (userId == null) {
            throw new BadRequestException(appMessages.get("admin.error.user.badId"));
        }
        return userDeviceService.listActiveByUserId(userId).stream()
                .map(userDeviceMapstruct::toDTO)
                .collect(Collectors.toList());
    }

    /**
     * 返回当前登录管理员资料；非员工返回 null。
     */
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
