package cn.nine.pros.post.client.model.input.admin;

import cn.nine.commons.data.dto.AbstractDTO;
import cn.nine.commons.data.page.PageQuery;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@Schema(description = "公告查询入参")
public class AnnouncementQueryInDto extends AbstractDTO {

    @Valid
    @NotNull(message = "分页参数不能为空")
    @Schema(description = "分页参数")
    private PageQuery page;
}