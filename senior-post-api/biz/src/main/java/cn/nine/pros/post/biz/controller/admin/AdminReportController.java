package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.model.domain.ReportDomain;
import cn.nine.pros.post.biz.model.mapstruct.ReportMapstruct;
import cn.nine.pros.post.biz.service.base.ReportService;
import cn.nine.pros.post.client.api.admin.AdminReportApi;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.db.ReportDTO;
import cn.nine.pros.post.client.model.input.admin.ReportHandleInDto;
import cn.nine.pros.post.client.model.input.admin.ReportQueryInDto;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequiredArgsConstructor
@Tag(name = "管理后台-举报管理API")
public class AdminReportController implements AdminReportApi {

    private final ReportService reportService;
    private final ReportMapstruct reportMapstruct;

    @Override
    @Operation(summary = "举报列表")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/report/list")
    public PageData<ReportDTO> listReports(@RequestBody ReportQueryInDto query) {
        PageQuery pageQuery = query.getPage();
        long pageNum = pageQuery.getPage();
        long pageSize = pageQuery.getSize();

        LambdaQueryWrapper<ReportDomain> wrapper = new LambdaQueryWrapper<>();
        if (query.getStatus() != null) {
            wrapper.eq(ReportDomain::getStatus, query.getStatus());
        }
        wrapper.eq(ReportDomain::isDelFlag, false);
        wrapper.orderByDesc(ReportDomain::getCreatedAt);

        Page<ReportDomain> page = reportService.page(new Page<>((int) pageNum, (int) pageSize), wrapper);
        List<ReportDTO> records = page.getRecords().stream().map(reportMapstruct::toDTO).toList();

        PageData<ReportDTO> result = new PageData<>();
        result.setRecords(records);
        result.setTotal(page.getTotal());
        result.setPages(page.getPages());
        result.setPage(page.getCurrent());
        result.setSize(page.getSize());
        return result;
    }

    @Override
    @Operation(summary = "处理举报")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/report/{id}/handle")
    @Transactional
    public void handleReport(@PathVariable("id") Long id, @RequestBody ReportHandleInDto req) {
        ReportDomain report = reportService.getById(id);
        if (report == null) {
            throw new cn.nine.commons.basic.exception.BadRequestException("举报不存在");
        }
        report.setStatus((short) 1);
        Long adminId = MyRequestContextHolder.userIdNum();
        if (adminId != null) {
            report.setHandlerUserId(adminId);
        }
        report.setHandleNote(req.getHandleNote());
        reportService.updateById(report);
    }

    @Override
    @Operation(summary = "驳回举报")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/report/{id}/reject")
    @Transactional
    public void rejectReport(@PathVariable("id") Long id, @RequestBody ReportHandleInDto req) {
        ReportDomain report = reportService.getById(id);
        if (report == null) {
            throw new cn.nine.commons.basic.exception.BadRequestException("举报不存在");
        }
        report.setStatus((short) 2);
        Long adminId = MyRequestContextHolder.userIdNum();
        if (adminId != null) {
            report.setHandlerUserId(adminId);
        }
        report.setHandleNote(req.getHandleNote());
        reportService.updateById(report);
    }
}
