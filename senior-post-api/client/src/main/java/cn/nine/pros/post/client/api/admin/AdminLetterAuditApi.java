package cn.nine.pros.post.client.api.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.db.LetterDTO;
import cn.nine.pros.post.client.model.input.admin.AdminIdListInDto;
import cn.nine.pros.post.client.model.input.admin.LetterAuditQueryInDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

@Tag(name = "管理后台-信件审核")
@RequestMapping(AppServiceDefine.WEBAPI_PREFIX + "/letter-audit")
public interface AdminLetterAuditApi {

    @Operation(summary = "分页查询待审/已审信件")
    @PostMapping("/paging")
    PageData<LetterDTO> paging(@RequestBody @Valid LetterAuditQueryInDto body);

    @Operation(summary = "审核通过")
    @PostMapping("/{id}/approve")
    void approve(@PathVariable("id") Long id);

    @Operation(summary = "审核拒绝并中止投递")
    @PostMapping("/{id}/reject")
    void reject(@PathVariable("id") Long id);

    @Operation(summary = "批量审核通过")
    @PostMapping("/batch-approve")
    void batchApprove(@RequestBody @Valid AdminIdListInDto body);

    @Operation(summary = "批量审核拒绝")
    @PostMapping("/batch-reject")
    void batchReject(@RequestBody @Valid AdminIdListInDto body);
}
