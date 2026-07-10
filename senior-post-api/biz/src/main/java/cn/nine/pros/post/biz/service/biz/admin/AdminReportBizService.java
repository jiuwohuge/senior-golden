package cn.nine.pros.post.biz.service.biz.admin;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.controller.admin.AdminPageHelper;
import cn.nine.pros.post.biz.model.domain.ReportDomain;
import cn.nine.pros.post.biz.model.mapstruct.ReportMapstruct;
import cn.nine.pros.post.biz.service.base.ReportService;
import cn.nine.pros.post.client.model.db.ReportDTO;
import cn.nine.pros.post.client.model.input.admin.ReportHandleInDto;
import cn.nine.pros.post.client.model.input.admin.ReportQueryInDto;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 管理端举报处理：分页查询、通过与驳回。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AdminReportBizService {

    private final ReportService reportService;
    private final ReportMapstruct reportMapstruct;

    /**
     * 按状态/目标类型分页查询举报。
     */
    public PageData<ReportDTO> paging(ReportQueryInDto body) {
        PageQuery pageQuery = AdminPageHelper.normalize(body.getPage());
        Page<ReportDomain> p = reportService.pageForAdmin(pageQuery, body.getStatus(), body.getTargetType());
        List<ReportDTO> list = p.getRecords().stream().map(reportMapstruct::toDTO).collect(Collectors.toList());
        return AdminPageHelper.pageData(pageQuery, p, list);
    }

    /**
     * 通过举报并记录处理备注。
     */
    public void handle(Long id, ReportHandleInDto body) {
        reportService.handleReport(id, 1, body.getHandleNote(), MyRequestContextHolder.userId());
        log.info("report handled (accept), reportId={}, adminId={}", id, MyRequestContextHolder.userId());
    }

    /**
     * 驳回举报并记录处理备注。
     */
    public void reject(Long id, ReportHandleInDto body) {
        reportService.handleReport(id, 2, body.getHandleNote(), MyRequestContextHolder.userId());
        log.info("report handled (reject), reportId={}, adminId={}", id, MyRequestContextHolder.userId());
    }
}
