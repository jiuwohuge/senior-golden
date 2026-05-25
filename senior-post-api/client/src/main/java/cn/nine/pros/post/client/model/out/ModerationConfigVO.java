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
@Schema(description = "明信片机审开关（管理后台）")
public class ModerationConfigVO {

    @Schema(description = "是否开启明信片配图鉴黄（百度）")
    private Boolean postcardImageEnabled;

    @Schema(description = "是否开启明信片正文鉴黄（DeepSeek）")
    private Boolean postcardTextEnabled;

    @Schema(description = "服务端是否已配置百度凭证（不回传密钥）")
    private Boolean baiduCredentialsReady;

    @Schema(description = "服务端是否已配置 DeepSeek API Key")
    private Boolean deepseekCredentialsReady;
}
