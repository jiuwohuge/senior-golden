package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.mapper.UserMapper;
import cn.nine.pros.post.biz.model.domain.UserIdentityDomain;
import cn.nine.pros.post.biz.model.domain.UserDomain;
import cn.nine.pros.post.biz.model.mapstruct.UserMapstruct;
import cn.nine.pros.post.biz.service.base.UserIdentityService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.client.model.db.UserDTO;
import cn.nine.pros.post.biz.support.PageQueryNormalize;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class UserServiceImpl extends ServiceImpl<UserMapper, UserDomain>
        implements UserService {

    @Autowired
    private UserMapstruct userMapstruct;

    @Autowired
    private AppMessages appMessages;

    @Autowired
    private UserIdentityService userIdentityService;

    @Override
    public void upsert(UserDTO userDTO) {
        Long id = userDTO.getId();
        if (id == null) {
            UserDomain domain = userMapstruct.toDomain(userDTO);
            domain.initAudit(MyRequestContextHolder.userId());
            save(domain);
            return;
        }
        UserDomain domain = userMapstruct.toDomain(userDTO);
        domain.setId(id);
        domain.setUpdatedAt(LocalDateTime.now());
        domain.setUpdatedBy(MyRequestContextHolder.userId());
        updateById(domain);
    }

    @Override
    public UserDTO findById(Long id) {
        UserDomain domain = getById(id);
        if (domain == null) {
            return null;
        }
        UserDTO dto = userMapstruct.toDTO(domain);
        enrichAuthFields(dto);
        return dto;
    }

    @Override
    public void delByIds(List<Long> ids) {
        if (ids == null || ids.isEmpty()) {
            return;
        }
        long staffCount = count(new LambdaQueryWrapper<UserDomain>()
                .in(UserDomain::getId, ids)
                .eq(UserDomain::isDelFlag, false)
                .isNotNull(UserDomain::getStaffRole)
                .ne(UserDomain::getStaffRole, 0));
        if (staffCount > 0) {
            throw new BadRequestException(appMessages.get("admin.error.user.cannotDeleteStaff"));
        }
        List<UserDomain> targets = list(new LambdaQueryWrapper<UserDomain>()
                .in(UserDomain::getId, ids)
                .eq(UserDomain::isDelFlag, false));
        LocalDateTime now = LocalDateTime.now();
        Long operatorId = MyRequestContextHolder.userId();
        long updatedBy = operatorId != null ? operatorId : 0L;
        for (UserDomain user : targets) {
            userIdentityService.releaseAllForUser(user.getId(), now);
            update(new LambdaUpdateWrapper<UserDomain>()
                    .eq(UserDomain::getId, user.getId())
                    .set(UserDomain::isDelFlag, true)
                    .set(UserDomain::getUpdatedAt, now)
                    .set(UserDomain::getUpdatedBy, updatedBy));
        }
    }

    @Override
    public UserDTO findByEmail(String email) {
        UserIdentityDomain ident = userIdentityService.findActiveEmailByUid(email.trim().toLowerCase());
        if (ident == null) {
            return null;
        }
        UserDomain u = getById(ident.getUserId());
        if (u == null || u.isDelFlag()) {
            return null;
        }
        UserDTO dto = userMapstruct.toDTO(u);
        dto.setEmail(ident.getProviderUid());
        dto.setPasswordHash(ident.getPasswordHash());
        return dto;
    }

    @Override
    public long countActiveAppUsers() {
        return count(new LambdaQueryWrapper<UserDomain>()
                .eq(UserDomain::isDelFlag, false)
                .apply("status = 1")
                .eq(UserDomain::getStaffRole, 0));
    }

    @Override
    public void updateWritingStyle(long userId, String writingStyle) {
        LocalDateTime now = LocalDateTime.now();
        update(new LambdaUpdateWrapper<UserDomain>()
                .eq(UserDomain::getId, userId)
                .set(UserDomain::getWritingStyle, writingStyle)
                .set(UserDomain::getUpdatedAt, now)
                .set(UserDomain::getUpdatedBy, userId));
    }

    @Override
    public void updateStatus(long userId, int status) {
        LocalDateTime now = LocalDateTime.now();
        update(new LambdaUpdateWrapper<UserDomain>()
                .eq(UserDomain::getId, userId)
                .set(UserDomain::getStatus, status)
                .set(UserDomain::getUpdatedAt, now)
                .set(UserDomain::getUpdatedBy, userId));
    }

    @Override
    public void markEmailVerified(long userId) {
        LocalDateTime now = LocalDateTime.now();
        update(new LambdaUpdateWrapper<UserDomain>()
                .eq(UserDomain::getId, userId)
                .set(UserDomain::getEmailVerified, true)
                .set(UserDomain::getUpdatedAt, now)
                .set(UserDomain::getUpdatedBy, userId));
    }

    @Override
    public void markFirstLetterDone(long userId) {
        LocalDateTime now = LocalDateTime.now();
        // 兼容历史 NULL：仅排除已为 true 的行。
        update(new LambdaUpdateWrapper<UserDomain>()
                .eq(UserDomain::getId, userId)
                .and(w -> w.eq(UserDomain::getFirstLetterDone, false)
                        .or()
                        .isNull(UserDomain::getFirstLetterDone))
                .set(UserDomain::getFirstLetterDone, true)
                .set(UserDomain::getUpdatedAt, now)
                .set(UserDomain::getUpdatedBy, userId));
    }

    @Override
    public void markLoginSuccess(long userId, String languageIfEmpty) {
        LocalDateTime now = LocalDateTime.now();
        LambdaUpdateWrapper<UserDomain> uw = new LambdaUpdateWrapper<UserDomain>()
                .eq(UserDomain::getId, userId)
                .set(UserDomain::getLastLoginAt, now)
                .set(UserDomain::getDeletionRequestedAt, null)
                .set(UserDomain::getUpdatedAt, now)
                .set(UserDomain::getUpdatedBy, userId);
        if (shouldApplyLanguageIfEmpty(userId, languageIfEmpty)) {
            uw.set(UserDomain::getLanguage, languageIfEmpty);
        }
        update(uw);
    }

    /** 仅当用户尚未设置语言时写入登录态语言偏好。 */
    private boolean shouldApplyLanguageIfEmpty(long userId, String languageIfEmpty) {
        if (languageIfEmpty == null || languageIfEmpty.isBlank()) {
            return false;
        }
        UserDomain u = getById(userId);
        return u != null && (u.getLanguage() == null || u.getLanguage().isBlank());
    }

    @Override
    public void requestDeletion(long userId) {
        LocalDateTime now = LocalDateTime.now();
        update(new LambdaUpdateWrapper<UserDomain>()
                .eq(UserDomain::getId, userId)
                .eq(UserDomain::isDelFlag, false)
                .set(UserDomain::getDeletionRequestedAt, now)
                .set(UserDomain::getUpdatedAt, now)
                .set(UserDomain::getUpdatedBy, userId));
    }

    @Override
    public void finalizeDeletion(long userId) {
        LocalDateTime now = LocalDateTime.now();
        update(new LambdaUpdateWrapper<UserDomain>()
                .eq(UserDomain::getId, userId)
                .eq(UserDomain::isDelFlag, false)
                .set(UserDomain::getStatus, 3)
                .set(UserDomain::getDeletionRequestedAt, null)
                .set(UserDomain::getUpdatedAt, now)
                .set(UserDomain::getUpdatedBy, userId));
    }

    @Override
    public void touchUpdatedAt(long userId) {
        LocalDateTime now = LocalDateTime.now();
        update(new LambdaUpdateWrapper<UserDomain>()
                .eq(UserDomain::getId, userId)
                .set(UserDomain::getUpdatedAt, now)
                .set(UserDomain::getUpdatedBy, userId));
    }

    @Override
    public com.baomidou.mybatisplus.extension.plugins.pagination.Page<UserDomain> pageDirectory(
            long viewerUserId,
            cn.nine.pros.post.client.model.input.app.AppDirectoryPageInDto body,
            cn.nine.commons.data.page.PageQuery pageQuery) {
        LambdaQueryWrapper<UserDomain> qw = new LambdaQueryWrapper<UserDomain>()
                .eq(UserDomain::isDelFlag, false)
                .apply("status = 1")
                .eq(UserDomain::getStaffRole, 0)
                .ne(UserDomain::getId, viewerUserId)
                .apply("NOT EXISTS (SELECT 1 FROM bu_user_blacklist bl WHERE bl.del_flag = FALSE "
                        + "AND ((bl.user_id = {0} AND bl.blocked_user_id = bu_user.id) "
                        + "OR (bl.user_id = bu_user.id AND bl.blocked_user_id = {0})))", viewerUserId);

        String sort = "DEFAULT";
        if (body != null && org.springframework.util.StringUtils.hasText(body.getSort())) {
            sort = body.getSort().trim().toUpperCase();
        }
        applyDirectorySort(qw, sort, viewerUserId);
        applyDirectoryGenderFilter(qw, body);
        if (body != null && org.springframework.util.StringUtils.hasText(body.getCountryCode())) {
            qw.eq(UserDomain::getCountryCode, body.getCountryCode().trim());
        }
        int year = java.time.LocalDate.now().getYear();
        if (body != null && body.getMinAge() != null && body.getMinAge() > 0) {
            qw.le(UserDomain::getBirthYear, year - body.getMinAge());
        }
        if (body != null && body.getMaxAge() != null && body.getMaxAge() > 0) {
            qw.ge(UserDomain::getBirthYear, year - body.getMaxAge());
        }
        applyDirectoryInterestFilters(qw, body);

        return page(PageQueryNormalize.mpPage(pageQuery, PageQueryNormalize.APP_MAX_SIZE), qw);
    }

    @Override
    public com.baomidou.mybatisplus.extension.plugins.pagination.Page<UserDomain> pageForAdmin(
            cn.nine.commons.data.page.PageQuery pageQuery,
            String email, String nickname, Integer status, Integer avatarAuditStatus,
            Integer gender, String countryCode, Integer minBirthYear, Integer maxBirthYear,
            Boolean isVip,
            LocalDateTime createdFrom, LocalDateTime createdTo,
            LocalDateTime lastLoginFrom, LocalDateTime lastLoginTo,
            String sortField, String sortOrder) {
        LambdaQueryWrapper<UserDomain> qw = new LambdaQueryWrapper<UserDomain>()
                .eq(UserDomain::isDelFlag, false);
        if (email != null && !email.isBlank()) {
            String emailLike = "%" + email.trim().toLowerCase() + "%";
            qw.apply(
                    "EXISTS (SELECT 1 FROM bu_user_identity i WHERE i.user_id = bu_user.id "
                            + "AND i.del_flag = FALSE AND i.provider = 'email' "
                            + "AND i.provider_uid LIKE {0} AND i.provider_uid NOT LIKE '%+deleted.%')",
                    emailLike);
        }
        if (nickname != null && !nickname.isBlank()) {
            qw.like(UserDomain::getNickname, nickname.trim());
        }
        if (status != null) {
            qw.eq(UserDomain::getStatus, status);
        }
        if (avatarAuditStatus != null) {
            qw.eq(UserDomain::getAvatarAuditStatus, avatarAuditStatus);
        }
        if (gender != null) {
            qw.eq(UserDomain::getGender, gender);
        }
        if (countryCode != null && !countryCode.isBlank()) {
            qw.eq(UserDomain::getCountryCode, countryCode.trim());
        }
        if (minBirthYear != null) {
            qw.ge(UserDomain::getBirthYear, minBirthYear);
        }
        if (maxBirthYear != null) {
            qw.le(UserDomain::getBirthYear, maxBirthYear);
        }
        if (isVip != null) {
            qw.eq(UserDomain::getIsVip, isVip);
        }
        if (createdFrom != null) {
            qw.ge(UserDomain::getCreatedAt, createdFrom);
        }
        if (createdTo != null) {
            qw.le(UserDomain::getCreatedAt, createdTo);
        }
        if (lastLoginFrom != null) {
            qw.ge(UserDomain::getLastLoginAt, lastLoginFrom);
        }
        if (lastLoginTo != null) {
            qw.le(UserDomain::getLastLoginAt, lastLoginTo);
        }
        applyAdminSort(qw, sortField, sortOrder);
        return page(PageQueryNormalize.mpPage(pageQuery, PageQueryNormalize.ADMIN_MAX_SIZE), qw);
    }

    private static void applyAdminSort(LambdaQueryWrapper<UserDomain> qw, String sortField, String sortOrder) {
        boolean asc = sortOrder != null && "asc".equalsIgnoreCase(sortOrder.trim());
        String field = sortField == null ? "" : sortField.trim();
        if ("lastLoginAt".equalsIgnoreCase(field)) {
            if (asc) {
                qw.orderByAsc(UserDomain::getLastLoginAt);
            } else {
                qw.orderByDesc(UserDomain::getLastLoginAt);
            }
            return;
        }
        if ("id".equalsIgnoreCase(field)) {
            if (asc) {
                qw.orderByAsc(UserDomain::getId);
            } else {
                qw.orderByDesc(UserDomain::getId);
            }
            return;
        }
        if (asc) {
            qw.orderByAsc(UserDomain::getCreatedAt);
        } else {
            qw.orderByDesc(UserDomain::getCreatedAt);
        }
    }

    @Override
    public void adminUpdateStatus(long userId, int status, Long auditUserId) {
        LocalDateTime now = LocalDateTime.now();
        update(new LambdaUpdateWrapper<UserDomain>()
                .eq(UserDomain::getId, userId)
                .set(UserDomain::getStatus, status)
                .set(UserDomain::getUpdatedBy, auditUserId)
                .set(UserDomain::getUpdatedAt, now));
    }

    @Override
    public void adminBatchUpdateStatus(java.util.Collection<Long> userIds, int status, Long auditUserId) {
        if (userIds == null || userIds.isEmpty()) {
            return;
        }
        LocalDateTime now = LocalDateTime.now();
        update(new LambdaUpdateWrapper<UserDomain>()
                .in(UserDomain::getId, userIds)
                .eq(UserDomain::isDelFlag, false)
                .set(UserDomain::getStatus, status)
                .set(UserDomain::getUpdatedBy, auditUserId)
                .set(UserDomain::getUpdatedAt, now));
    }

    @Override
    public void adminUpdateProfile(long userId, Integer status, Integer birthYear, String nickname,
                                   String countryCode, String bio, String avatarUrl, Integer avatarAuditStatus,
                                   Long auditUserId) {
        LocalDateTime now = LocalDateTime.now();
        LambdaUpdateWrapper<UserDomain> uw = new LambdaUpdateWrapper<UserDomain>()
                .eq(UserDomain::getId, userId)
                .set(status != null, UserDomain::getStatus, status)
                .set(birthYear != null, UserDomain::getBirthYear, birthYear)
                .set(nickname != null, UserDomain::getNickname, nickname)
                .set(countryCode != null, UserDomain::getCountryCode, countryCode)
                .set(bio != null, UserDomain::getBio, bio)
                .set(UserDomain::getUpdatedBy, auditUserId)
                .set(UserDomain::getUpdatedAt, now);
        if (avatarAuditStatus != null) {
            uw.set(UserDomain::getAvatarUrl, avatarUrl);
            uw.set(UserDomain::getAvatarAuditStatus, avatarAuditStatus);
        }
        update(uw);
    }

    @Override
    public void adminUpdateAvatarAudit(long userId, int avatarAuditStatus, Long auditUserId) {
        LocalDateTime now = LocalDateTime.now();
        update(new LambdaUpdateWrapper<UserDomain>()
                .eq(UserDomain::getId, userId)
                .set(UserDomain::getAvatarAuditStatus, avatarAuditStatus)
                .set(UserDomain::getUpdatedBy, auditUserId)
                .set(UserDomain::getUpdatedAt, now));
    }

    @Override
    public void adminUpdateVipDebug(long userId, boolean isVip, java.time.LocalDateTime vipExpireAt,
                                    boolean clearVipExpireAt, Long auditUserId) {
        LocalDateTime now = LocalDateTime.now();
        LambdaUpdateWrapper<UserDomain> uw = new LambdaUpdateWrapper<UserDomain>()
                .eq(UserDomain::getId, userId)
                .set(UserDomain::getIsVip, isVip)
                .set(UserDomain::getUpdatedAt, now)
                .set(UserDomain::getUpdatedBy, auditUserId);
        if (clearVipExpireAt) {
            uw.set(UserDomain::getVipExpireAt, null);
        } else if (vipExpireAt != null) {
            uw.set(UserDomain::getVipExpireAt, vipExpireAt);
        }
        update(uw);
    }

    @Override
    public List<UserDomain> listActiveAppUsersExcluding(long excludeUserId, int limit) {
        return list(new LambdaQueryWrapper<UserDomain>()
                .eq(UserDomain::isDelFlag, false)
                .apply("status = 1")
                .eq(UserDomain::getStaffRole, 0)
                .ne(UserDomain::getId, excludeUserId)
                .orderByDesc(UserDomain::getId)
                .last("LIMIT " + Math.max(1, limit)));
    }

    @Override
    public long countCreatedBetween(LocalDateTime start, LocalDateTime end) {
        LambdaQueryWrapper<UserDomain> qw = new LambdaQueryWrapper<UserDomain>()
                .eq(UserDomain::isDelFlag, false);
        if (start != null) {
            qw.ge(UserDomain::getCreatedAt, start);
        }
        if (end != null) {
            qw.lt(UserDomain::getCreatedAt, end);
        }
        return count(qw);
    }

    private void enrichAuthFields(UserDTO dto) {
        if (dto == null || dto.getId() == null) {
            return;
        }
        UserIdentityDomain email = userIdentityService.findActiveEmailIdentity(dto.getId());
        if (email != null) {
            dto.setEmail(email.getProviderUid());
            dto.setPasswordHash(email.getPasswordHash());
        }
    }

    /** 通讯录排序：同龄优先 / 共同兴趣 / 默认创建时间。 */
    private void applyDirectorySort(LambdaQueryWrapper<UserDomain> qw, String sort, long viewerUserId) {
        if ("SAME_AGE".equals(sort)) {
            applySameAgeSort(qw, viewerUserId);
            return;
        }
        if ("SHARED_INTEREST".equals(sort)) {
            qw.last("ORDER BY (SELECT COUNT(*)::int FROM bu_user_tag ut INNER JOIN bu_user_tag ut2 ON ut.tag_id = ut2.tag_id "
                    + "AND ut2.user_id = " + viewerUserId + " AND ut2.del_flag = FALSE "
                    + "WHERE ut.user_id = bu_user.id AND ut.del_flag = FALSE) DESC NULLS LAST, created_at DESC");
            return;
        }
        qw.orderByDesc(UserDomain::getCreatedAt);
    }

    private void applySameAgeSort(LambdaQueryWrapper<UserDomain> qw, long viewerUserId) {
        UserDomain viewer = getById(viewerUserId);
        Integer vy = viewer != null ? viewer.getBirthYear() : null;
        if (vy == null || vy <= 0) {
            qw.orderByDesc(UserDomain::getCreatedAt);
            return;
        }
        qw.last("ORDER BY CASE WHEN birth_year IS NULL THEN 999 ELSE ABS(birth_year - "
                + vy + ") END ASC, created_at DESC");
    }

    private void applyDirectoryGenderFilter(
            LambdaQueryWrapper<UserDomain> qw,
            cn.nine.pros.post.client.model.input.app.AppDirectoryPageInDto body) {
        if (body == null || body.getGenders() == null || body.getGenders().isEmpty()) {
            return;
        }
        java.util.List<Integer> genders = body.getGenders().stream()
                .filter(g -> g != null && g >= 1 && g <= 3)
                .distinct()
                .toList();
        if (genders.isEmpty()) {
            return;
        }
        qw.in(UserDomain::getGender, genders);
    }

    private void applyDirectoryInterestFilters(
            LambdaQueryWrapper<UserDomain> qw,
            cn.nine.pros.post.client.model.input.app.AppDirectoryPageInDto body) {
        if (body == null || body.getInterestNames() == null || body.getInterestNames().isEmpty()) {
            return;
        }
        for (String n : body.getInterestNames()) {
            applyOneInterestNameFilter(qw, n);
        }
    }

    private void applyOneInterestNameFilter(LambdaQueryWrapper<UserDomain> qw, String n) {
        if (!org.springframework.util.StringUtils.hasText(n)) {
            return;
        }
        qw.apply("EXISTS (SELECT 1 FROM bu_user_tag ut INNER JOIN sys_tag t ON t.id = ut.tag_id AND t.del_flag = FALSE "
                + "WHERE ut.user_id = bu_user.id AND ut.del_flag = FALSE AND t.tag_name = {0})", n.trim());
    }
}
