package cn.nine.pros.post.client.model.input.admin;

import cn.nine.commons.data.dto.AbstractDTO;
import cn.nine.commons.data.page.PageQuery;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.Valid;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@Schema(description = "评论查询入参")
public class CommentQueryInDto extends AbstractDTO {

    @Valid
    @Schema(description = "分页参数")
    private PageQuery page;

    @Schema(description = "审核状态：0待审核 1通过 2驳回")
    private Integer reviewStatus;

    @Schema(description = "明信片ID")
    private Long postcardId;
}