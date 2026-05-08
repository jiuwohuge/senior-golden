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
@Schema(description = "单个 objectKey 的 GET 预签名结果")
public class OssGetSignItemVO {

    @Schema(description = "对象键（与请求一致）")
    private String objectKey;

    @Schema(description = "带签名的 GET URL，可直接用于 Image.network / img src")
    private String signedUrl;

    @Schema(description = "签名过期时间（毫秒时间戳）")
    private Long expireAtEpochMillis;
}
