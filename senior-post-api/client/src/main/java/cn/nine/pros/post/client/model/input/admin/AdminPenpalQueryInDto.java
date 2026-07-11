package cn.nine.pros.post.client.model.input.admin;

import cn.nine.commons.data.dto.AbstractDTO;
import cn.nine.commons.data.page.PageQuery;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.Valid;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

@Data
@EqualsAndHashCode(callSuper = true)
@Schema(description = "笔友关系查询")
public class AdminPenpalQueryInDto extends AbstractDTO {

    @Valid
    @Schema(description = "分页参数")
    private PageQuery page;

    @Schema(description = "用户 ID（匹配 userLow 或 userHigh）")
    private Long userId;

    @Schema(description = "对端用户 ID")
    private Long peerId;

    @Schema(description = "建立时间起")
    private LocalDateTime createdFrom;

    @Schema(description = "建立时间止")
    private LocalDateTime createdTo;
}
