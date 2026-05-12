package cn.nine.pros.post.client.model.input.app;

import cn.nine.pros.post.client.common.enums.LetterPhysicalType;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * App 发送信件（挂号 / 平邮）。
 */
@Data
@Schema(description = "发送信件")
public class AppSendLetterInDto {

    @NotNull
    @Schema(description = "收件人用户 ID", requiredMode = Schema.RequiredMode.REQUIRED)
    private Long toUserId;

    @NotBlank
    @Size(max = 20000)
    @Schema(description = "信件正文", requiredMode = Schema.RequiredMode.REQUIRED)
    private String content;

    /**
     * 见 {@link LetterPhysicalType}：{@link LetterPhysicalType#REGISTERED} 或 {@link LetterPhysicalType#STANDARD}。
     */
    @NotNull
    @Schema(description = "LetterPhysicalType.code：1=REGISTERED（挂号信）2=STANDARD（平邮）", requiredMode = Schema.RequiredMode.REQUIRED)
    private Integer letterType;

    @Schema(description = "回复的原信件 ID；若填写则仅收信人可发，且收件人自动为原发件人")
    private Long parentLetterId;
}
