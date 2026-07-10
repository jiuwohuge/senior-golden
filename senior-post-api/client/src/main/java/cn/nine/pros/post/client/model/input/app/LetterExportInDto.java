package cn.nine.pros.post.client.model.input.app;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDate;

@Data
@Schema(description = "信件导出入参")
public class LetterExportInDto {

    @Schema(description = "笔友用户 ID（可选，空则导出全部往来）")
    private Long peerUserId;

    @Schema(description = "起始日期（含）")
    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
    private LocalDate fromDate;

    @Schema(description = "结束日期（含）")
    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
    private LocalDate toDate;
}
