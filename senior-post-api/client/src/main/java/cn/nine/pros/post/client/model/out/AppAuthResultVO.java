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
}
