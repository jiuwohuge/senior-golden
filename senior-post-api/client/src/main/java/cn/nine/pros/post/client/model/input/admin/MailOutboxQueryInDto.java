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
@Schema(description = "系统邮件出站查询")
public class MailOutboxQueryInDto extends AbstractDTO {

    @Valid
    @Schema(description = "分页参数")
    private PageQuery page;

    @Schema(description = "收件邮箱（模糊）")
    private String toEmail;

    @Schema(description = "邮件类型")
    private String mailType;

    @Schema(description = "状态：pending/sending/sent/failed")
    private String status;

    @Schema(description = "创建时间起")
    private LocalDateTime createdFrom;

    @Schema(description = "创建时间止")
    private LocalDateTime createdTo;

    @Schema(description = "关键词（payload/邮箱）")
    private String keyword;
}
