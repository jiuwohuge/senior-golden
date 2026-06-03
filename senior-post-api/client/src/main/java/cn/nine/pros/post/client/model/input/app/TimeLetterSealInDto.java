package cn.nine.pros.post.client.model.input.app;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDate;

@Data
@Schema(description = "封缄时光信")
public class TimeLetterSealInDto {

    @Schema(description = "草稿 ID，从草稿封缄时传入")
    private Long draftId;

    @Schema(description = "收件人 ID，写给自己时为空")
    private Long recipientId;

    @NotBlank
    @Schema(description = "正文")
    private String body;

    @Schema(description = "内容标签")
    private String contentTag;

    @Schema(description = "情感标签")
    private String emotionTag;

    @Schema(description = "信纸主题")
    private String paperTheme;

    @Schema(description = "信纸颜色")
    private String paperColor;

    @NotNull
    @Schema(description = "送达日期")
    private LocalDate deliveryDate;

    @NotBlank
    @Schema(description = "送达时区 IANA ID")
    private String deliveryTz;

    @Schema(description = "写作城市")
    private String writerCity;

    @Schema(description = "写作时长（秒）")
    private Integer writeDurationSec;

    @NotBlank
    @Schema(description = "封缄幂等请求 ID")
    private String sealRequestId;
}
