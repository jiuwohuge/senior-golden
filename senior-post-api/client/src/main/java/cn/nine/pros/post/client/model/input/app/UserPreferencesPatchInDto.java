package cn.nine.pros.post.client.model.input.app;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.util.Map;

@Data
@Schema(description = "用户偏好 PATCH（部分字段）")
public class UserPreferencesPatchInDto {

    @Schema(description = "隐私偏好增量")
    private Map<String, Object> privacy;

    @Schema(description = "通知偏好增量")
    private Map<String, Object> notifications;
}
