package cn.nine.pros.post.client.api.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.db.StampTransactionDTO;
import cn.nine.pros.post.client.model.input.admin.AdminStampLedgerPageInDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@Tag(name = "管理后台-邮票")
public interface AdminStampsApi {

    @Operation(summary = "邮票流水分页（全量或按用户/原因筛选）")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/stamps/ledger/paging")
    PageData<StampTransactionDTO> ledgerPaging(@RequestBody @Valid AdminStampLedgerPageInDto body);
}
