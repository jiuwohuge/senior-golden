package cn.nine.pros.post.client.model.input.app;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.util.List;

@Data
@Schema(description = "批量申请 OSS 私有对象 GET 预签名 URL")
public class AppOssGetSignInDto {

    @Valid
    @NotEmpty
    @Size(max = 32)
    @Schema(description = "对象键列表（须为本业务上传路径，见 put-sign 返回的 objectKey）")
    private List<@NotBlank @Size(max = 1024) String> objectKeys;
}
