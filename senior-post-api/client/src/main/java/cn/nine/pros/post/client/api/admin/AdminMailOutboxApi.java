package cn.nine.pros.post.client.api.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.input.admin.MailOutboxQueryInDto;
import cn.nine.pros.post.client.model.out.MailOutboxVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

@Tag(name = "管理后台-系统邮件出站")
@RequestMapping(AppServiceDefine.WEBAPI_PREFIX + "/mail-outbox")
public interface AdminMailOutboxApi {

    @Operation(summary = "出站邮件分页")
    @PostMapping("/paging")
    PageData<MailOutboxVO> paging(@RequestBody @Valid MailOutboxQueryInDto body);

    @Operation(summary = "出站邮件详情")
    @GetMapping("/{id}")
    MailOutboxVO detail(@PathVariable("id") Long id);

    @Operation(summary = "失败重试（重置为 pending）")
    @PostMapping("/{id}/retry")
    void retry(@PathVariable("id") Long id);
}
