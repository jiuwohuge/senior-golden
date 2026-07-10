package cn.nine.pros.post.client.model.input.app;

import cn.nine.pros.post.client.model.json.UserNotificationPrefs;
import cn.nine.pros.post.client.model.json.UserPrivacyPrefs;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

@Data
@Schema(description = "用户偏好 PATCH（部分字段）")
public class UserPreferencesPatchInDto {

    @Schema(description = "隐私偏好增量")
    private UserPrivacyPrefs privacy;

    @Schema(description = "通知偏好增量")
    private UserNotificationPrefs notifications;
}
