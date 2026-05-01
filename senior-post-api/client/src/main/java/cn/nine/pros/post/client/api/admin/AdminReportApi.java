package cn.nine.pros.post.client.api.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.db.ReportDTO;
import cn.nine.pros.post.client.model.input.admin.ReportHandleInDto;
import cn.nine.pros.post.client.model.input.admin.ReportQueryInDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

@Tag(name = "管理后台-举报")
public interface AdminReportApi {

    @Operation(summary = "分页查询举报")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/report/paging")
    PageData<ReportDTO> paging(@RequestBody @Valid ReportQueryInDto body);

    @Operation(summary = "处理举报")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/report/{id}/handle")
    void handle(@PathVariable("id") Long id, @RequestBody @Valid ReportHandleInDto body);

    @Operation(summary = "驳回举报")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/report/{id}/reject")
    void reject(@PathVariable("id") Long id, @RequestBody @Valid ReportHandleInDto body);
}
