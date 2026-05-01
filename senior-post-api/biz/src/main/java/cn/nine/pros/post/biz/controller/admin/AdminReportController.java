package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.model.domain.ReportDomain;
import cn.nine.pros.post.biz.model.mapstruct.ReportMapstruct;
import cn.nine.pros.post.biz.service.base.ReportService;
import cn.nine.pros.post.client.api.admin.AdminReportApi;
import cn.nine.pros.post.client.model.db.ReportDTO;
import cn.nine.pros.post.client.model.input.admin.ReportHandleInDto;
import cn.nine.pros.post.client.model.input.admin.ReportQueryInDto;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.apache.commons.lang3.StringUtils;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequiredArgsConstructor
public class AdminReportController implements AdminReportApi {

    private final ReportService reportService;
    private final ReportMapstruct reportMapstruct;

    @Override
    public PageData<ReportDTO> paging(ReportQueryInDto body) {
        PageQuery pageQuery = AdminPageHelper.normalize(body.getPage());
        LambdaQueryWrapper<ReportDomain> qw = new LambdaQueryWrapper<ReportDomain>()
                .eq(ReportDomain::isDelFlag, false)
                .orderByDesc(ReportDomain::getCreatedAt);
        if (body.getStatus() != null) {
            qw.eq(ReportDomain::getStatus, body.getStatus());
        }
        if (StringUtils.isNotBlank(body.getTargetType())) {
            qw.eq(ReportDomain::getTargetType, body.getTargetType().trim());
        }
        Page<ReportDomain> p = reportService.page(AdminPageHelper.mpPage(pageQuery), qw);
        List<ReportDTO> list = p.getRecords().stream().map(reportMapstruct::toDTO).collect(Collectors.toList());
        return AdminPageHelper.pageData(pageQuery, p, list);
    }

    @Override
    public void handle(Long id, ReportHandleInDto body) {
        reportService.update(new LambdaUpdateWrapper<ReportDomain>()
                .eq(ReportDomain::getId, id)
                .set(ReportDomain::getStatus, 1)
                .set(ReportDomain::getHandleNote, body.getHandleNote())
                .set(ReportDomain::getHandlerUserId, MyRequestContextHolder.userIdNum()));
    }

    @Override
    public void reject(Long id, ReportHandleInDto body) {
        reportService.update(new LambdaUpdateWrapper<ReportDomain>()
                .eq(ReportDomain::getId, id)
                .set(ReportDomain::getStatus, 2)
                .set(ReportDomain::getHandleNote, body.getHandleNote())
                .set(ReportDomain::getHandlerUserId, MyRequestContextHolder.userIdNum()));
    }
}
