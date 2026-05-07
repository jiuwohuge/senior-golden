package cn.nine.pros.post.client.model.input.app;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.util.List;

@Data
@Schema(description = "发布明信片（待审核）")
public class AppPostcardCreateInDto {

    @NotBlank
    @Size(max = 2000)
    @Schema(description = "正文")
    private String content;

    @Size(max = 9)
    @Schema(description = "配图 URL 列表（可选，建议先走 OSS 预签名上传）")
    private List<@Size(max = 2048) String> imageUrls;
}
