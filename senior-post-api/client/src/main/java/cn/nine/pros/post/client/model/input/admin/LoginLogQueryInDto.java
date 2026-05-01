package cn.nine.pros.post.client.model.input.admin;

import cn.nine.commons.data.dto.AbstractDTO;
import cn.nine.commons.data.page.PageQuery;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.Valid;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@Schema(description = "登录日志查询入参")
public class LoginLogQueryInDto extends AbstractDTO {

    @Valid
    @Schema(description = "分页参数")
    private PageQuery page;

    @Schema(description = "用户ID")
    private Long userId;

    @Schema(description = "登录结果：1成功 2失败")
    private Integer loginResult;
}