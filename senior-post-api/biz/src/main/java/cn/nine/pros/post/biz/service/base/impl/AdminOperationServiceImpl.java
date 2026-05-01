package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.nine.pros.post.biz.mapper.AdminOperationMapper;
import cn.nine.pros.post.biz.model.domain.AdminOperationDomain;
import cn.nine.pros.post.biz.model.mapstruct.AdminOperationMapstruct;
import cn.nine.pros.post.biz.service.base.AdminOperationService;
import cn.nine.pros.post.client.model.db.AdminOperationDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 管理员操作日志表 ServiceImpl
 *
 * @author Administrator
 */
@Service
public class AdminOperationServiceImpl extends ServiceImpl<AdminOperationMapper, AdminOperationDomain>
        implements AdminOperationService {

    @Autowired
    private AdminOperationMapstruct adminOperationMapstruct;

    @Override
    public void upsert(AdminOperationDTO adminOperationDTO) {
        Long id = adminOperationDTO.getId();
        if (id == null) {
            AdminOperationDomain domain = adminOperationMapstruct.toDomain(adminOperationDTO);
            domain.initAudit(MyRequestContextHolder.userId());
            save(domain);
            return;
        }
        AdminOperationDomain domain = adminOperationMapstruct.toDomain(adminOperationDTO);
        domain.setId(id);
        domain.setUpdatedAt(LocalDateTime.now());
        domain.setUpdatedBy(MyRequestContextHolder.userId());
        updateById(domain);
    }

    @Override
    public AdminOperationDTO findById(Long id) {
        return adminOperationMapstruct.toDTO(getById(id));
    }

    @Override
    public void delByIds(List<Long> ids) {
        AdminOperationDomain adminOperationDomain = new AdminOperationDomain();
        adminOperationDomain.setDelFlag(true);
        adminOperationDomain.setUpdatedAt(LocalDateTime.now());
        update(adminOperationDomain, new LambdaQueryWrapper<AdminOperationDomain>()
                .in(AdminOperationDomain::getId, ids));
    }

}