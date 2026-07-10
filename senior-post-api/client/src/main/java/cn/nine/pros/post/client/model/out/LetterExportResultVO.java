package cn.nine.pros.post.client.model.out;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "信件导出结果")
public class LetterExportResultVO {

    @Schema(description = "下载 URL（OSS 签名或占位）")
    private String downloadUrl;
}
