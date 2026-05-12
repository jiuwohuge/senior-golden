package cn.nine.pros.post.client.api.app;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.db.StampTransactionDTO;
import cn.nine.pros.post.client.model.input.app.AppStampLedgerPageInDto;
import cn.nine.pros.post.client.model.out.AppStampBalanceVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

@Tag(name = "App-邮票")
@RequestMapping(AppServiceDefine.SERVER_PREFIX + "/stamps")
public interface AppStampsApi {

    @Operation(summary = "当前用户邮票余额与 VIP 摘要")
    @GetMapping("/balance")
    AppStampBalanceVO balance();

    @Operation(summary = "当前用户邮票流水分页")
    @PostMapping("/ledger/paging")
    PageData<StampTransactionDTO> ledgerPaging(@RequestBody AppStampLedgerPageInDto body);
}
