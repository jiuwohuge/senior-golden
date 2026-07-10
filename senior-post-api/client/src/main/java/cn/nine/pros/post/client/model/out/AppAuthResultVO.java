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
@Schema(description = "App 登录/注册返回")
public class AppAuthResultVO {

    @Schema(description = "JWT，请求头 Token 携带")
    private String token;

    @Schema(description = "用户信息")
    private AppPublicUserVO user;

    @Schema(description = "资料是否已满足 45+、性别、兴趣≥3 等必填项")
    private Boolean profileComplete;

    @Schema(description = "登录风险：0无 1轻 2中 3高")
    private Integer riskLevel;

    @Schema(description = "中风险时为 true：需邮箱二次验证后再发 Token")
    private Boolean requireEmailChallenge;
}
