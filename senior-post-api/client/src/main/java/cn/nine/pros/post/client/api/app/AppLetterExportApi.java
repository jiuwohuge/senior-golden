package cn.nine.pros.post.client.api.app;

import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.input.app.LetterExportInDto;
import cn.nine.pros.post.client.model.out.LetterExportResultVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

@Tag(name = "App-信件导出")
@RequestMapping(AppServiceDefine.SERVER_PREFIX + "/letters")
public interface AppLetterExportApi {

    @Operation(summary = "导出往来信件（MVP 文本/PDF 占位）")
    @PostMapping("/export")
    LetterExportResultVO export(@RequestBody @Valid LetterExportInDto body);
}
