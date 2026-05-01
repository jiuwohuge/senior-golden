package cn.nine.pros.post.client.model.input.admin;

import cn.nine.commons.data.dto.AbstractDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@Schema(description = "举报处理入参")
public class ReportHandleInDto extends AbstractDTO {

    @Schema(description = "处理备注")
    private String handleNote;

    @Schema(description = "处理结果：1已处理 2已驳回")
    private Integer result;
}