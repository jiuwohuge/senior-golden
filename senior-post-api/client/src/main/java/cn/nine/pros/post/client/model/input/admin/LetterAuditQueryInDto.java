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
@Schema(description = "信件审核/运营查询入参")
public class LetterAuditQueryInDto extends AbstractDTO {

    @Valid
    @Schema(description = "分页参数")
    private PageQuery page;

    @Schema(description = "审核状态：0待审 1通过 2拒绝")
    private Integer auditStatus;

    @Schema(description = "产品模式：1POST_OFFICE 2DIRECT")
    private Integer mode;

    @Schema(description = "信件业务状态")
    private Integer status;

    @Schema(description = "发件人用户 ID")
    private Long fromUserId;

    @Schema(description = "收件人用户 ID")
    private Long toUserId;

    @Schema(description = "正文关键词（模糊）")
    private String keyword;

    @Schema(description = "创建时间起")
    private LocalDateTime createdFrom;

    @Schema(description = "创建时间止")
    private LocalDateTime createdTo;
}
