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
@Schema(description = "Moderation provider credential readiness")
public class ModerationConfigVO {

    @Schema(description = "Baidu credentials configured on server")
    private Boolean baiduCredentialsReady;

    @Schema(description = "DeepSeek API key configured on server")
    private Boolean deepseekCredentialsReady;
}
