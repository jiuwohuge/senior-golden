package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.nine.pros.post.biz.mapper.AdminUserMapper;
import cn.nine.pros.post.biz.model.domain.AdminUserDomain;
import cn.nine.pros.post.biz.model.mapstruct.AdminUserMapstruct;
import cn.nine.pros.post.biz.service.base.AdminUserService;
import cn.nine.pros.post.client.model.db.AdminUserDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 管理员表 ServiceImpl
 *
 * @author Administrator
 */
@Service
public class AdminUserServiceImpl extends ServiceImpl<AdminUserMapper, AdminUserDomain>
        implements AdminUserService {

    @Autowired
    private AdminUserMapstruct adminUserMapstruct;

    @Override
    public void upsert(AdminUserDTO adminUserDTO) {
        Long id = adminUserDTO.getId();
        if (id == null) {
            AdminUserDomain domain = adminUserMapstruct.toDomain(adminUserDTO);
            domain.initAudit(MyRequestContextHolder.userId());
            save(domain);
            return;
        }
        AdminUserDomain domain = adminUserMapstruct.toDomain(adminUserDTO);
        domain.setId(id);
        domain.setUpdatedAt(LocalDateTime.now());
        domain.setUpdatedBy(MyRequestContextHolder.userId());
        updateById(domain);
    }

    @Override
    public AdminUserDTO findById(Long id) {
        return adminUserMapstruct.toDTO(getById(id));
    }

    @Override
    public void delByIds(List<Long> ids) {
        AdminUserDomain adminUserDomain = new AdminUserDomain();
        adminUserDomain.setDelFlag(true);
        adminUserDomain.setUpdatedAt(LocalDateTime.now());
        update(adminUserDomain, new LambdaQueryWrapper<AdminUserDomain>()
                .in(AdminUserDomain::getId, ids));
    }

}