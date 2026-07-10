package cn.nine.pros.post.client.api.app;

import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.input.app.LetterDraftSaveInDto;
import cn.nine.pros.post.client.model.out.LetterDraftVO;
import cn.nine.pros.post.client.model.out.MailboxLetterItemVO;
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

@Tag(name = "App-信件草稿")
@RequestMapping(AppServiceDefine.SERVER_PREFIX + "/letter-drafts")
public interface AppLetterDraftApi {

    @Operation(summary = "草稿列表")
    @GetMapping
    List<LetterDraftVO> listDrafts();

    @Operation(summary = "保存草稿")
    @PostMapping("/save")
    LetterDraftVO saveDraft(@RequestBody @Valid LetterDraftSaveInDto body);

    @Operation(summary = "删除草稿")
    @DeleteMapping("/{id}")
    void deleteDraft(@PathVariable("id") Long id);

    @Operation(summary = "发送草稿（转正式发信）")
    @PostMapping("/{id}/send")
    MailboxLetterItemVO sendDraft(@PathVariable("id") Long id);
}
