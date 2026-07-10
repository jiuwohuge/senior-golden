package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.pros.post.biz.support.PageQueryNormalize;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.nine.pros.post.biz.mapper.ReportMapper;
import cn.nine.pros.post.biz.model.domain.ReportDomain;
import cn.nine.pros.post.biz.model.mapstruct.ReportMapstruct;
import cn.nine.pros.post.biz.service.base.ReportService;
import cn.nine.pros.post.client.model.db.ReportDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 举报工单表 ServiceImpl
 *
 * @author Administrator
 */
@Service
public class ReportServiceImpl extends ServiceImpl<ReportMapper, ReportDomain>
        implements ReportService {

    @Autowired
    private ReportMapstruct reportMapstruct;

    @Override
    public void upsert(ReportDTO reportDTO) {
        Long id = reportDTO.getId();
        if (id == null) {
            ReportDomain domain = reportMapstruct.toDomain(reportDTO);
            domain.initAudit(MyRequestContextHolder.userId());
            save(domain);
            return;
        }
        ReportDomain domain = reportMapstruct.toDomain(reportDTO);
        domain.setId(id);
        domain.setUpdatedAt(LocalDateTime.now());
        domain.setUpdatedBy(MyRequestContextHolder.userId());
        updateById(domain);
    }

    @Override
    public ReportDTO findById(Long id) {
        return reportMapstruct.toDTO(getById(id));
    }

    @Override
    public void delByIds(List<Long> ids) {
        ReportDomain reportDomain = new ReportDomain();
        reportDomain.setDelFlag(true);
        reportDomain.setUpdatedAt(LocalDateTime.now());
        update(reportDomain, new LambdaQueryWrapper<ReportDomain>()
                .in(ReportDomain::getId, ids));
    }

    @Override
    public long countPendingByReporterTarget(long reporterUserId, String targetType, long targetId) {
        return count(new LambdaQueryWrapper<ReportDomain>()
                .eq(ReportDomain::isDelFlag, false)
                .eq(ReportDomain::getReporterUserId, reporterUserId)
                .eq(ReportDomain::getTargetType, targetType)
                .eq(ReportDomain::getTargetId, targetId)
                .apply("status = 0"));
    }

    @Override
    public long countPending() {
        return count(new LambdaQueryWrapper<ReportDomain>()
                .eq(ReportDomain::isDelFlag, false)
                .eq(ReportDomain::getStatus, 0));
    }


    @Override
    public com.baomidou.mybatisplus.extension.plugins.pagination.Page<ReportDomain> pageForAdmin(
            cn.nine.commons.data.page.PageQuery pageQuery, Integer status, String targetType) {
        LambdaQueryWrapper<ReportDomain> qw = new LambdaQueryWrapper<ReportDomain>()
                .eq(ReportDomain::isDelFlag, false)
                .orderByDesc(ReportDomain::getCreatedAt);
        if (status != null) {
            qw.eq(ReportDomain::getStatus, status);
        }
        if (targetType != null && !targetType.isBlank()) {
            qw.eq(ReportDomain::getTargetType, targetType.trim());
        }
        return page(PageQueryNormalize.mpPage(pageQuery, PageQueryNormalize.ADMIN_MAX_SIZE), qw);
    }

    @Override
    public boolean handleReport(long id, int status, String handleNote, Long handlerUserId) {
        return update(new com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper<ReportDomain>()
                .eq(ReportDomain::getId, id)
                .set(ReportDomain::getStatus, status)
                .set(ReportDomain::getHandleNote, handleNote)
                .set(ReportDomain::getHandlerUserId, handlerUserId));
    }

}