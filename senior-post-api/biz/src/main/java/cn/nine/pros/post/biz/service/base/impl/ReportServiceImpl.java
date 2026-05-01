package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
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

}