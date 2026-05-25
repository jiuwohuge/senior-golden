package cn.nine.pros.post.client.model.input.app;

import cn.nine.commons.data.page.PageQuery;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

@Data
@Schema(description = "明信片墙分页")
public class AppPostcardPageInDto {

    @Schema(description = "分页参数")
    private PageQuery page;

    @Schema(description = "true 时仅返回邮政好友（Connections）的已通过明信片")
    private Boolean connectionsOnly;
}
