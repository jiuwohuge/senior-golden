package cn.nine.pros.post.client.model.out;

import cn.nine.pros.post.client.model.json.UserNotificationPrefs;
import cn.nine.pros.post.client.model.json.UserPrivacyPrefs;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "用户隐私与通知偏好")
public class UserPreferencesVO {

    @Schema(description = "隐私偏好")
    private UserPrivacyPrefs privacy;

    @Schema(description = "通知偏好")
    private UserNotificationPrefs notifications;
}
