package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.mapper.UserMapper;
import cn.nine.pros.post.biz.model.domain.UserDomain;
import cn.nine.pros.post.biz.model.mapstruct.UserMapstruct;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.client.model.db.UserDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 用户主表 ServiceImpl
 *
 * @author Administrator
 */
@Service
public class UserServiceImpl extends ServiceImpl<UserMapper, UserDomain>
        implements UserService {

    @Autowired
    private UserMapstruct userMapstruct;

    @Autowired
    private AppMessages appMessages;

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
        return userMapstruct.toDTO(getById(id));
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
        UserDomain userDomain = new UserDomain();
        userDomain.setDelFlag(true);
        userDomain.setUpdatedAt(LocalDateTime.now());
        update(userDomain, new LambdaQueryWrapper<UserDomain>()
                .in(UserDomain::getId, ids));
    }

    @Override
    public UserDTO findByEmail(String email) {
        UserDomain u = getOne(new LambdaQueryWrapper<UserDomain>()
                .eq(UserDomain::getEmail, email)
                .eq(UserDomain::isDelFlag, false));
        return u == null ? null : userMapstruct.toDTO(u);
    }

}