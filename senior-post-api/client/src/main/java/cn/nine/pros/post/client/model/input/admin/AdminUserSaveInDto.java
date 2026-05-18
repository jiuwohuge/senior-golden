package cn.nine.pros.post.client.model.input.admin;

import cn.nine.commons.data.dto.AbstractDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@Schema(description = "管理端编辑用户入参")
public class AdminUserSaveInDto extends AbstractDTO {

    @NotNull
    @Schema(description = "用户ID", requiredMode = Schema.RequiredMode.REQUIRED)
    private Long id;

    @Schema(description = "昵称")
    private String nickname;

    @Schema(description = "出生年份")
    private Integer birthYear;

    @Schema(description = "国家代码")
    private String countryCode;

    @Schema(description = "个人简介")
    private String bio;

    @Schema(description = "状态：1正常 2封禁 3注销")
    private Integer status;
}
