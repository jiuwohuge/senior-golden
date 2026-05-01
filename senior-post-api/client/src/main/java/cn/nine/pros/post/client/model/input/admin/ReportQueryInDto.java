package cn.nine.pros.post.client.model.input.admin;

import cn.nine.commons.data.dto.AbstractDTO;
import cn.nine.commons.data.page.PageQuery;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.Valid;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@Schema(description = "举报查询入参")
public class ReportQueryInDto extends AbstractDTO {

    @Valid
    @Schema(description = "分页参数")
    private PageQuery page;

    @Schema(description = "处理状态：0待处理 1已处理 2已驳回")
    private Integer status;

    @Schema(description = "目标类型：postcard/comment/letter")
    private String targetType;
}