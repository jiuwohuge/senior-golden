package cn.nine.pros.post.client.model.input.app;

import cn.nine.pros.post.client.common.enums.LetterMode;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * App 发送信件：DIRECT 需收件人；POST_OFFICE 可不指定收件人。
 */
@Data
@Schema(description = "发送信件")
public class AppSendLetterInDto {

    @Schema(description = "收件人用户 ID；POST_OFFICE 可空；回信时可由 parentLetterId 推导")
    private Long toUserId;

    @NotBlank
    @Size(max = 20000)
    @Schema(description = "信件正文", requiredMode = Schema.RequiredMode.REQUIRED)
    private String content;

    /**
     * 兼容旧客户端；服务端统一强制 STANDARD（§6.2，速度仅由距离+关系决定）。
     */
    @Schema(description = "已废弃：忽略挂号/平邮；服务端固定 STANDARD=2")
    private Integer letterType;

    @Schema(description = "回复的原信件 ID；若填写则仅收信人可发，且收件人自动为原发件人")
    private Long parentLetterId;

    /**
     * 见 {@link LetterMode}；缺省：有 toUserId/回信 → DIRECT，否则 POST_OFFICE。
     */
    @Schema(description = "LetterMode.code：1=POST_OFFICE 2=DIRECT；可空由服务端推断")
    private Integer mode;

    @Schema(description = "信纸皮肤 ID，默认 default")
    private String skinId;

    @Schema(description = "字体 ID，默认 default")
    private String fontId;

    @Schema(description = "写信模板 ID")
    private String templateId;
}
