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

    @Schema(description = "头像审核：0待审核 1通过 2驳回")
    private Integer avatarAuditStatus;

    @Schema(description = "性别：0未设置 1男 2女")
    private Integer gender;

    @Schema(description = "国家代码")
    private String countryCode;

    @Schema(description = "出生年份下限（含）")
    private Integer minBirthYear;

    @Schema(description = "出生年份上限（含）")
    private Integer maxBirthYear;

    @Schema(description = "是否 VIP")
    private Boolean isVip;

    @Schema(description = "注册时间起")
    private LocalDateTime createdFrom;

    @Schema(description = "注册时间止")
    private LocalDateTime createdTo;

    @Schema(description = "最后登录时间起")
    private LocalDateTime lastLoginFrom;

    @Schema(description = "最后登录时间止")
    private LocalDateTime lastLoginTo;

    @Schema(description = "排序字段：createdAt / lastLoginAt / id")
    private String sortField;

    @Schema(description = "排序方向：asc / desc，默认 desc")
    private String sortOrder;
}
