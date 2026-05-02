package cn.nine.pros.post.client.model.input.app;

import cn.nine.commons.data.page.PageQuery;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

/**
 * App 邮票流水分页入参。
 */
@Data
@Schema(description = "邮票流水分页查询")
public class AppStampLedgerPageInDto {

    @Schema(description = "分页参数")
    private PageQuery page;
}
