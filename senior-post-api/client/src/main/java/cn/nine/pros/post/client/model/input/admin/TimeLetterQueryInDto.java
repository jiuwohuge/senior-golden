package cn.nine.pros.post.client.model.input.admin;

import cn.nine.commons.data.page.PageQuery;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

@Data
@Schema(description = "管理端时光信分页")
public class TimeLetterQueryInDto {

    @Schema(description = "分页参数")
    private PageQuery page;

    @Schema(description = "发件人 ID")
    private Long senderId;

    @Schema(description = "收件人 ID")
    private Long recipientId;

    @Schema(description = "状态")
    private Integer status;
}
