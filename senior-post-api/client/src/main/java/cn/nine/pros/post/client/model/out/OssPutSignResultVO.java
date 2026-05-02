package cn.nine.pros.post.client.model.out;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 客户端直传 OSS 的 PUT 预签名结果。
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "OSS PUT 预签名")
public class OssPutSignResultVO {

    @Schema(description = "带签名的 PUT URL，请求体为文件二进制")
    private String putUrl;

    @Schema(description = "对象键，需与 PUT 时路径一致（已由服务端生成）")
    private String objectKey;

    @Schema(description = "建议的 Content-Type，客户端 PUT 时应携带相同值")
    private String contentType;

    @Schema(description = "过期时间（毫秒时间戳）")
    private Long expireAtEpochMillis;

    @Schema(description = "可选：公开读 URL（配置了 publicReadBaseUrl 时拼接）")
    private String readUrl;
}
