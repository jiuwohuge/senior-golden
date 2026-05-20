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
}
