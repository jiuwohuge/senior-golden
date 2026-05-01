package cn.nine.pros.post.client.model.input.admin;

import cn.nine.commons.data.dto.AbstractDTO;
import cn.nine.commons.data.page.PageQuery;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.Valid;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@Schema(description = "用户查询入参")
public class UserQueryInDto extends AbstractDTO {

    @Valid
    @Schema(description = "分页参数")
    private PageQuery page;

    @Schema(description = "邮箱（模糊搜索）")
    private String email;

    @Schema(description = "昵称（模糊搜索）")
    private String nickname;

    @Schema(description = "状态：1正常 2封禁")
    private Integer status;
}