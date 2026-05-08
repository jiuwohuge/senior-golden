package cn.nine.pros.post.client.model.input;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.util.List;

/**
 * App 更新个人资料（部分字段）；字段为 {@code null} 表示不修改。
 */
@Data
@Schema(description = "App 资料 PATCH 入参")
public class AppAuthProfilePatchInDto {

    @Size(max = 100)
    @Schema(description = "昵称；非 null 时更新且去首尾空格后不可为空")
    private String nickname;

    @Size(max = 10)
    @Schema(description = "国家代码；非 null 时更新，空串表示清空")
    private String countryCode;

    @Size(max = 2000)
    @Schema(description = "简介；非 null 时更新（可为空串）")
    private String bio;

    @Size(max = 512)
    @Schema(description = "头像对象存储引用（通常为 objectKey）；非 null 时更新，空串表示清空")
    private String avatarUrl;

    @Size(min = 3, max = 30)
    @Schema(description = "兴趣标签 ID 全量替换（非 null 时覆盖 bu_user_tag；至少 3 个）")
    private List<@NotNull Integer> interestTagIds;
}
