package cn.nine.pros.post.client.api.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.db.ReportDTO;
import cn.nine.pros.post.client.model.input.admin.ReportHandleInDto;
import cn.nine.pros.post.client.model.input.admin.ReportQueryInDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@Tag(name = "管理后台-举报管理API")
public interface AdminReportApi {

    @Operation(summary = "举报列表")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/report/list")
    PageData<ReportDTO> listReports(@RequestBody @Validated ReportQueryInDto query);

    @Operation(summary = "处理举报")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/report/{id}/handle")
    void handleReport(@PathVariable("id") Long id, @RequestBody @Validated ReportHandleInDto req);

    @Operation(summary = "驳回举报")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/report/{id}/reject")
    void rejectReport(@PathVariable("id") Long id, @RequestBody @Validated ReportHandleInDto req);
}