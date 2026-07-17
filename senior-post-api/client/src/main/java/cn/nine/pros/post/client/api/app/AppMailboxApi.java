package cn.nine.pros.post.client.api.app;

import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.input.app.AppLetterAssistantInDto;
import cn.nine.pros.post.client.model.input.app.AppSendLetterInDto;
import cn.nine.pros.post.client.model.out.AcceptPostalContactResultVO;
import cn.nine.pros.post.client.model.out.AppLetterAssistantVO;
import cn.nine.pros.post.client.model.out.LetterSyncResultVO;
import cn.nine.pros.post.client.model.out.MailboxFriendItemVO;
import cn.nine.pros.post.client.model.out.MailboxLetterItemVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.time.LocalDateTime;
import java.util.List;

@Tag(name = "App-邮政信箱")
@RequestMapping(AppServiceDefine.SERVER_PREFIX + "/mailbox")
public interface AppMailboxApi {

    @Operation(summary = "邮政待办（收件箱相关信件）")
    @GetMapping("/postal")
    List<MailboxLetterItemVO> listPostalInbox();

    @Operation(summary = "信件增量同步")
    @GetMapping("/sync")
    LetterSyncResultVO sync(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime since);

    @Operation(summary = "信件归档（含已建联历史）")
    @GetMapping("/archive")
    List<MailboxLetterItemVO> listArchive();

    @Operation(summary = "收到的信流水（§12.4）")
    @GetMapping("/received")
    List<MailboxLetterItemVO> listReceived();

    @Operation(summary = "发出的信流水（§12.4）")
    @GetMapping("/sent")
    List<MailboxLetterItemVO> listSent();

    @Operation(summary = "发起笔友申请（兼容旧 accept-postal 路径）")
    @PostMapping("/letters/{letterId}/accept-postal")
    AcceptPostalContactResultVO acceptPostalContact(@PathVariable("letterId") Long letterId);

    @Operation(summary = "发送信件（DIRECT 走 §6.1 延迟；POST_OFFICE 入池待匹配）")
    @PostMapping("/letters/send")
    MailboxLetterItemVO sendLetter(@RequestBody @Valid AppSendLetterInDto body);

    @Operation(summary = "信件详情（参与方可读，含正文）")
    @GetMapping("/letters/{letterId}")
    MailboxLetterItemVO getLetter(@PathVariable("letterId") Long letterId);

    @Operation(summary = "邮政好友列表（Connections）：基于 bu_friendship 活跃关系")
    @GetMapping("/friends")
    List<MailboxFriendItemVO> listFriends();

    @Operation(summary = "信件助手：整理原文建议稿（不自动覆盖）")
    @PostMapping("/letters/letter-assistant")
    AppLetterAssistantVO letterAssistant(@RequestBody @Valid AppLetterAssistantInDto body);
}
