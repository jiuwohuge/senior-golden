package cn.nine.pros.post.client.model.input.admin;

import cn.nine.commons.data.dto.AbstractDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

@Data
@EqualsAndHashCode(callSuper = true)
@Schema(description = "公告创建/更新入参")
public class AnnouncementInDto extends AbstractDTO {

    @Schema(description = "公告ID（更新时传入）")
    private Integer id;

    @NotBlank(message = "标题不能为空")
    @Schema(description = "标题")
    private String title;

    @Schema(description = "标题多语言JSON")
    private String titleJson;

    @NotBlank(message = "内容不能为空")
    @Schema(description = "内容")
    private String content;

    @Schema(description = "内容多语言JSON")
    private String contentJson;

    @Schema(description = "生效开始时间")
    private LocalDateTime startAt;

    @Schema(description = "生效结束时间")
    private LocalDateTime endAt;

    @Schema(description = "是否激活")
    private Boolean isActive;
}