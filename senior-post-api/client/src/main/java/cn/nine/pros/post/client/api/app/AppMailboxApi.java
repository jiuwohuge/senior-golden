package cn.nine.pros.post.client.api.app;

import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.input.app.AppSendLetterInDto;
import cn.nine.pros.post.client.model.out.AcceptPostalContactResultVO;
import cn.nine.pros.post.client.model.out.LetterSyncResultVO;
import cn.nine.pros.post.client.model.out.MailboxLetterItemVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;

import java.time.LocalDateTime;
import java.util.List;

@Tag(name = "App-邮政信箱")
public interface AppMailboxApi {

    @Operation(summary = "邮政待办（未与对端建立 IM 建联的信件）")
    @GetMapping(AppServiceDefine.SERVER_PREFIX + "/mailbox/postal")
    List<MailboxLetterItemVO> listPostalInbox();

    @Operation(summary = "信件增量同步")
    @GetMapping(AppServiceDefine.SERVER_PREFIX + "/mailbox/sync")
    LetterSyncResultVO sync(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime since);

    @Operation(summary = "信件归档（含已建联历史）")
    @GetMapping(AppServiceDefine.SERVER_PREFIX + "/mailbox/archive")
    List<MailboxLetterItemVO> listArchive();

    @Operation(summary = "收件方建立建联（好友），并触发腾讯 IM 同步占位")
    @PostMapping(AppServiceDefine.SERVER_PREFIX + "/mailbox/letters/{letterId}/accept-postal")
    AcceptPostalContactResultVO acceptPostalContact(@PathVariable("letterId") Long letterId);

    @Operation(summary = "发送信件（挂号即时送达 / 平邮运输中）；非 VIP 挂号消耗邮票")
    @PostMapping(AppServiceDefine.SERVER_PREFIX + "/mailbox/letters/send")
    MailboxLetterItemVO sendLetter(@RequestBody @Valid AppSendLetterInDto body);
}
