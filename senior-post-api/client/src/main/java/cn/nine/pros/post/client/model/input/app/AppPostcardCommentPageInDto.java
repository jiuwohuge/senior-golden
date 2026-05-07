package cn.nine.pros.post.client.model.input.app;

import cn.nine.commons.data.page.PageQuery;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

@Data
@Schema(description = "明信片评论分页")
public class AppPostcardCommentPageInDto {

    @Schema(description = "分页参数")
    private PageQuery page;
}
