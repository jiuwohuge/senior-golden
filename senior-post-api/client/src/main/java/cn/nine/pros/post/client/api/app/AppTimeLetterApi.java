package cn.nine.pros.post.client.api.app;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.input.app.TimeLetterDraftSaveInDto;
import cn.nine.pros.post.client.model.input.app.TimeLetterPageInDto;
import cn.nine.pros.post.client.model.input.app.TimeLetterPreviewDeliveryInDto;
import cn.nine.pros.post.client.model.input.app.TimeLetterSealInDto;
import cn.nine.pros.post.client.model.out.TimeLetterDetailVO;
import cn.nine.pros.post.client.model.out.TimeLetterListItemVO;
import cn.nine.pros.post.client.model.out.TimeLetterPreviewDeliveryVO;
import cn.nine.pros.post.client.model.out.TimeLetterRecentRecipientVO;
import cn.nine.pros.post.client.model.out.TimeLetterSealResultVO;
import cn.nine.pros.post.client.model.out.TimeLetterStatsVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;

@Tag(name = "App-时光邮局")
@RequestMapping(AppServiceDefine.SERVER_PREFIX + "/time-letter")
public interface AppTimeLetterApi {

    @Operation(summary = "保存草稿")
    @PostMapping("/draft")
    TimeLetterDetailVO saveDraft(@RequestBody @Valid TimeLetterDraftSaveInDto body);

    @Operation(summary = "读取草稿")
    @GetMapping("/draft/{id}")
    TimeLetterDetailVO getDraft(@PathVariable("id") Long id);

    @Operation(summary = "删除草稿")
    @DeleteMapping("/draft/{id}")
    void deleteDraft(@PathVariable("id") Long id);

    @Operation(summary = "封缄")
    @PostMapping("/seal")
    TimeLetterSealResultVO seal(@RequestBody @Valid TimeLetterSealInDto body);

    @Operation(summary = "24h 内取消")
    @PostMapping("/{id}/cancel")
    void cancel(@PathVariable("id") Long id);

    @Operation(summary = "发件箱分页")
    @PostMapping("/outbox/paging")
    PageData<TimeLetterListItemVO> outboxPaging(@RequestBody @Valid TimeLetterPageInDto body);

    @Operation(summary = "收件箱分页")
    @PostMapping("/inbox/paging")
    PageData<TimeLetterListItemVO> inboxPaging(@RequestBody @Valid TimeLetterPageInDto body);

    @Operation(summary = "纪念册分页（已读）")
    @PostMapping("/memorial/paging")
    PageData<TimeLetterListItemVO> memorialPaging(@RequestBody @Valid TimeLetterPageInDto body);

    @Operation(summary = "详情")
    @GetMapping("/{id}")
    TimeLetterDetailVO getDetail(@PathVariable("id") Long id);

    @Operation(summary = "拆信")
    @PostMapping("/{id}/open")
    TimeLetterDetailVO open(@PathVariable("id") Long id);

    @Operation(summary = "切换星标")
    @PostMapping("/{id}/star")
    void toggleStar(@PathVariable("id") Long id);

    @Operation(summary = "私密统计")
    @GetMapping("/stats")
    TimeLetterStatsVO stats();

    @Operation(summary = "送达日预览")
    @PostMapping("/preview-delivery")
    TimeLetterPreviewDeliveryVO previewDelivery(@RequestBody TimeLetterPreviewDeliveryInDto body);

    @Operation(summary = "最近收信人")
    @GetMapping("/recent-recipients")
    List<TimeLetterRecentRecipientVO> recentRecipients();
}
