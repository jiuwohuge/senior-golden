package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.pros.post.biz.mapper.AdminOperationMapper;
import cn.nine.pros.post.biz.model.domain.AdminOperationDomain;
import cn.nine.pros.post.biz.model.mapstruct.AdminOperationMapstruct;
import cn.nine.pros.post.biz.service.base.AdminOperationService;
import cn.nine.pros.post.biz.support.PageQueryNormalize;
import cn.nine.pros.post.client.model.db.AdminOperationDTO;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

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

    @Override
    public void record(long adminId, String actionType, String targetType, Long targetId, String details, String ip) {
        AdminOperationDomain row = new AdminOperationDomain();
        row.initAudit(adminId);
        row.setAdminId(adminId);
        row.setActionType(actionType);
        row.setTargetType(targetType);
        row.setTargetId(targetId);
        row.setDetails(toJsonbDetails(details));
        row.setIpAddress(ip);
        save(row);
    }

    /** Plain admin notes become {"note":"..."} so jsonb insert never sees illegal JSON text. */
    private static Object toJsonbDetails(String details) {
        if (!StringUtils.hasText(details)) {
            return null;
        }
        String trimmed = details.trim();
        if ((trimmed.startsWith("{") && trimmed.endsWith("}"))
                || (trimmed.startsWith("[") && trimmed.endsWith("]"))) {
            return trimmed;
        }
        Map<String, String> map = new LinkedHashMap<>(1);
        map.put("note", trimmed);
        return map;
    }

    @Override
    public Page<AdminOperationDomain> pageForAdmin(
            cn.nine.commons.data.page.PageQuery pageQuery,
            Long adminId, String actionType, String targetType) {
        LambdaQueryWrapper<AdminOperationDomain> qw = new LambdaQueryWrapper<AdminOperationDomain>()
                .eq(AdminOperationDomain::isDelFlag, false)
                .orderByDesc(AdminOperationDomain::getCreatedAt);
        if (adminId != null) {
            qw.eq(AdminOperationDomain::getAdminId, adminId);
        }
        if (StringUtils.hasText(actionType)) {
            qw.eq(AdminOperationDomain::getActionType, actionType.trim());
        }
        if (StringUtils.hasText(targetType)) {
            qw.eq(AdminOperationDomain::getTargetType, targetType.trim());
        }
        return page(PageQueryNormalize.mpPage(pageQuery, PageQueryNormalize.ADMIN_MAX_SIZE), qw);
    }

}
