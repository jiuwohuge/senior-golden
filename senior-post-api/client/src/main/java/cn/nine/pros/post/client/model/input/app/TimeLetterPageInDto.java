package cn.nine.pros.post.client.model.input.app;

import cn.nine.commons.data.page.PageQuery;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

@Data
@Schema(description = "时光信分页")
public class TimeLetterPageInDto {

    @Schema(description = "分页参数")
    private PageQuery page;

    @Schema(description = "仅星标（纪念册）")
    private Boolean starredOnly;
}
