package cn.nine.pros.post.client.model.out;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "明信片作者摘要")
public class PostcardAuthorVO {

    @Schema(description = "用户 ID")
    private Long userId;

    @Schema(description = "昵称")
    private String nickname;

    @Schema(description = "国家代码")
    private String countryCode;

    @Schema(description = "国家展示名（可空）")
    private String countryName;

    @Schema(description = "头像 URL")
    private String avatarUrl;
}
