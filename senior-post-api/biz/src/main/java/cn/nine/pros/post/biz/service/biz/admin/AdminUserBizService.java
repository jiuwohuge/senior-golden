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
import cn.nine.pros.post.biz.service.base.ConfigService;
import cn.nine.pros.post.biz.service.base.DailyQuotaClaimService;
import cn.nine.pros.post.biz.service.base.LetterService;
import cn.nine.pros.post.biz.service.base.UserDeviceService;
import cn.nine.pros.post.biz.service.base.UserIdentityService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.biz.service.biz.admin.support.AdminOperationRecorder;
import cn.nine.pros.post.biz.service.biz.support.DailyQuotaSupport;
import cn.nine.pros.post.biz.service.biz.support.OssReadableKeyValidator;
import cn.nine.pros.post.biz.service.biz.support.UserAvatarAuditSupport;
import cn.nine.pros.post.client.model.db.UserDTO;
import cn.nine.pros.post.client.model.db.UserDeviceDTO;
import cn.nine.pros.post.client.model.input.admin.AdminIdListInDto;
import cn.nine.pros.post.client.model.input.admin.AdminUserBatchStatusInDto;
import cn.nine.pros.post.client.model.input.admin.AdminUserQuotaAdjustInDto;
import cn.nine.pros.post.client.model.input.admin.AdminUserSaveInDto;
import cn.nine.pros.post.client.model.input.admin.AdminUserVipDebugInDto;
import cn.nine.pros.post.client.model.input.admin.DeviceBlockInDto;
import cn.nine.pros.post.client.model.input.admin.UserQueryInDto;
import cn.nine.pros.post.client.model.out.AdminUserBriefVO;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

/**
 * 管理端用户运营：分页、状态、资料、头像审核、VIP 调试与设备封禁。
 */
@Slf4j
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
    private final AdminOperationRecorder adminOperationRecorder;
    private final ConfigService configService;
    private final DailyQuotaClaimService dailyQuotaClaimService;
    private final LetterService letterService;

    /**
     * 多维筛选 + 排序分页查询用户；附加当日免费额度快照。
     */
    public PageData<UserDTO> paging(UserQueryInDto body) {
        PageQuery pageQuery = AdminPageHelper.normalize(body.getPage());
        Page<UserDomain> p = userService.pageForAdmin(
                pageQuery,
                body.getEmail(), body.getNickname(), body.getStatus(), body.getAvatarAuditStatus(),
                body.getGender(), body.getCountryCode(), body.getMinBirthYear(), body.getMaxBirthYear(),
                body.getIsVip(),
                body.getCreatedFrom(), body.getCreatedTo(),
                body.getLastLoginFrom(), body.getLastLoginTo(),
                body.getSortField(), body.getSortOrder());
        List<UserDTO> list = p.getRecords().stream()
                .map(u -> userService.findById(u.getId()))
                .filter(dto -> dto != null)
                .peek(this::attachQuotaSnapshot)
                .collect(Collectors.toList());
        return AdminPageHelper.pageData(pageQuery, p, list);
    }

    /**
     * 单用户详情（含当日免费额度），供 /user?edit= 打开编辑弹窗。
     */
    public UserDTO detail(Long id) {
        if (id == null) {
            throw new BadRequestException(appMessages.get("admin.error.user.badId"));
        }
        UserDTO dto = userService.findById(id);
        if (dto == null) {
            throw new BadRequestException(appMessages.get("admin.error.user.notFound"));
        }
        attachQuotaSnapshot(dto);
        return dto;
    }

    /**
     * 批量用户摘要，供各业务列表渲染「头像+昵称」。
     */
    public List<AdminUserBriefVO> briefs(AdminIdListInDto body) {
        List<Long> ids = distinctIds(body.getIds());
        if (ids.isEmpty()) {
            return List.of();
        }
        List<AdminUserBriefVO> out = new ArrayList<>(ids.size());
        for (Long id : ids) {
            UserDTO dto = userService.findById(id);
            if (dto == null) {
                continue;
            }
            out.add(AdminUserBriefVO.builder()
                    .id(dto.getId())
                    .nickname(dto.getNickname())
                    .avatarUrl(dto.getAvatarUrl())
                    .build());
        }
        return out;
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
        adminOperationRecorder.record("user.status", "user", id, "status=" + status);
        log.info("admin update user status, userId={}, status={}", id, status);
    }

    /**
     * 批量更新用户状态。
     */
    @Transactional(rollbackFor = Exception.class)
    public void batchStatus(AdminUserBatchStatusInDto body) {
        Integer status = body.getStatus();
        if (status == null || (status != 1 && status != 2 && status != 3)) {
            throw new BadRequestException(appMessages.get("admin.error.user.badStatus"));
        }
        List<Long> ids = body.getIds();
        if (status == 3) {
            LocalDateTime now = LocalDateTime.now();
            for (Long id : ids) {
                userIdentityService.releaseAllForUser(id, now);
            }
        }
        userService.adminBatchUpdateStatus(ids, status, auditUserId());
        for (Long id : ids) {
            adminOperationRecorder.record("user.batch_status", "user", id, "status=" + status);
        }
        log.info("admin batch update user status, count={}, status={}", ids.size(), status);
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
        adminOperationRecorder.record("user.save", "user", id, null);
        log.info("admin save user, userId={}", id);
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
        adminOperationRecorder.record("user.delete", "user", id, null);
        log.info("admin delete user, userId={}", id);
    }

    /**
     * 通过用户头像审核。
     */
    public void approveAvatar(Long id) {
        updateAvatarAudit(id, UserAvatarAuditSupport.APPROVED);
        adminOperationRecorder.record("user.avatar_approve", "user", id, null);
    }

    /**
     * 驳回用户头像审核。
     */
    public void rejectAvatar(Long id) {
        updateAvatarAudit(id, UserAvatarAuditSupport.REJECTED);
        adminOperationRecorder.record("user.avatar_reject", "user", id, null);
    }

    /**
     * 批量通过头像审核；无头像用户跳过。
     */
    @Transactional(rollbackFor = Exception.class)
    public void batchApproveAvatar(AdminIdListInDto body) {
        batchAvatarAudit(body, UserAvatarAuditSupport.APPROVED, "user.avatar_batch_approve");
    }

    /**
     * 批量驳回头像审核；无头像用户跳过。
     */
    @Transactional(rollbackFor = Exception.class)
    public void batchRejectAvatar(AdminIdListInDto body) {
        batchAvatarAudit(body, UserAvatarAuditSupport.REJECTED, "user.avatar_batch_reject");
    }

    private void batchAvatarAudit(AdminIdListInDto body, int targetStatus, String actionType) {
        List<Long> ids = distinctIds(body.getIds());
        int ok = 0;
        for (Long id : ids) {
            UserDomain user = userService.getById(id);
            if (user == null || user.isDelFlag() || !UserAvatarAuditSupport.hasStoredAvatar(user)) {
                continue;
            }
            int current = UserAvatarAuditSupport.statusOf(user);
            if (current == targetStatus) {
                continue;
            }
            userService.adminUpdateAvatarAudit(id, targetStatus, auditUserId());
            adminOperationRecorder.record(actionType, "user", id, "status=" + targetStatus);
            ok++;
        }
        log.info("admin batch avatar audit, action={}, requested={}, updated={}", actionType, ids.size(), ok);
    }

    /**
     * 调整用户当日免费发信剩余次数：quota_amount = sentToday + remainingQuota。
     */
    @Transactional(rollbackFor = Exception.class)
    public UserDTO adjustQuota(Long id, AdminUserQuotaAdjustInDto body) {
        if (id == null) {
            throw new BadRequestException(appMessages.get("admin.error.user.badId"));
        }
        UserDTO user = userService.findById(id);
        if (user == null) {
            throw new BadRequestException(appMessages.get("admin.error.user.notFound"));
        }
        Integer remaining = body.getRemainingQuota();
        if (remaining == null || remaining < 0) {
            throw new BadRequestException(appMessages.get("admin.error.user.badQuota"));
        }
        DailyQuotaSupport.Snapshot before = DailyQuotaSupport.resolve(
                id, user, configService, dailyQuotaClaimService, letterService);
        int newCap = before.sentToday() + remaining;
        dailyQuotaClaimService.upsertQuotaAmount(id, LocalDate.now(), newCap, auditUserId());
        adminOperationRecorder.record(
                "user.quota_adjust",
                "user",
                id,
                "remaining=" + remaining + ",cap=" + newCap);
        log.info("admin adjust daily quota, userId={}, remaining={}, cap={}", id, remaining, newCap);
        UserDTO refreshed = userService.findById(id);
        attachQuotaSnapshot(refreshed);
        return refreshed;
    }

    private void attachQuotaSnapshot(UserDTO dto) {
        if (dto == null || dto.getId() == null) {
            return;
        }
        DailyQuotaSupport.Snapshot snap = DailyQuotaSupport.resolve(
                dto.getId(), dto, configService, dailyQuotaClaimService, letterService);
        dto.setQuotaClaimedToday(snap.claimed());
        dto.setSentToday(snap.sentToday());
        dto.setDailyQuotaCap(snap.cap());
        dto.setRemainingQuota(snap.remaining());
    }

    private static List<Long> distinctIds(List<Long> raw) {
        if (raw == null || raw.isEmpty()) {
            return List.of();
        }
        return new ArrayList<>(new LinkedHashSet<>(raw.stream()
                .filter(Objects::nonNull)
                .collect(Collectors.toList())));
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
        log.info("admin avatar audit, userId={}, status={}", id, targetStatus);
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
