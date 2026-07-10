package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.biz.service.biz.admin.AdminReportBizService;
import cn.nine.pros.post.client.api.admin.AdminReportApi;
import cn.nine.pros.post.client.model.db.ReportDTO;
import cn.nine.pros.post.client.model.input.admin.ReportHandleInDto;
import cn.nine.pros.post.client.model.input.admin.ReportQueryInDto;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class AdminReportController implements AdminReportApi {

    private final AdminReportBizService adminReportBizService;

    @Override
    public PageData<ReportDTO> paging(ReportQueryInDto body) {
        return adminReportBizService.paging(body);
    }

    @Override
    public void handle(Long id, ReportHandleInDto body) {
        adminReportBizService.handle(id, body);
    }

    @Override
    public void reject(Long id, ReportHandleInDto body) {
        adminReportBizService.reject(id, body);
    }
}
