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
public class AppImUserSigVO {

    @Schema(description = "SDKAppID")
    private Long sdkAppId;

    @Schema(description = "IM 登录 userID（与业务用户ID字符串一致）")
    private String userId;

    @Schema(description = "UserSig")
    private String userSig;

    @Schema(description = "有效期（秒）")
    private Integer expireInSeconds;
}
