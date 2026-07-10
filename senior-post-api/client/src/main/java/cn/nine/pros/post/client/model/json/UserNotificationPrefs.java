package cn.nine.pros.post.client.model.json;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 用户通知偏好 notifications_json。
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonIgnoreProperties(ignoreUnknown = true)
@Schema(description = "通知偏好")
public class UserNotificationPrefs {

    @JsonProperty("push_enabled")
    @JsonAlias({"pushEnabled"})
    @Schema(description = "总推送开关")
    private Boolean pushEnabled;

    @JsonProperty("unread_badges")
    @JsonAlias({"unreadBadges"})
    @Schema(description = "未读红点")
    private Boolean unreadBadges;

    @Schema(description = "新信送达推送")
    private Boolean letterDelivered;

    @Schema(description = "笔友请求推送")
    private Boolean penpalRequest;

    @Schema(description = "笔友同意推送")
    private Boolean penpalAccepted;

    @Schema(description = "时光信开启推送")
    private Boolean timeLetterDelivered;

    @Schema(description = "审核拒绝推送")
    private Boolean auditRejected;

    public void mergeFrom(UserNotificationPrefs patch) {
        if (patch == null) {
            return;
        }
        if (patch.pushEnabled != null) {
            this.pushEnabled = patch.pushEnabled;
        }
        if (patch.unreadBadges != null) {
            this.unreadBadges = patch.unreadBadges;
        }
        if (patch.letterDelivered != null) {
            this.letterDelivered = patch.letterDelivered;
        }
        if (patch.penpalRequest != null) {
            this.penpalRequest = patch.penpalRequest;
        }
        if (patch.penpalAccepted != null) {
            this.penpalAccepted = patch.penpalAccepted;
        }
        if (patch.timeLetterDelivered != null) {
            this.timeLetterDelivered = patch.timeLetterDelivered;
        }
        if (patch.auditRejected != null) {
            this.auditRejected = patch.auditRejected;
        }
    }

    /** null 视为开启。 */
    public boolean isEventAllowed(String eventKey) {
        if (eventKey == null) {
            return true;
        }
        Boolean flag = switch (eventKey) {
            case "letterDelivered" -> letterDelivered;
            case "penpalRequest" -> penpalRequest;
            case "penpalAccepted" -> penpalAccepted;
            case "timeLetterDelivered" -> timeLetterDelivered;
            case "auditRejected" -> auditRejected;
            case "push_enabled", "pushEnabled" -> pushEnabled;
            default -> null;
        };
        return flag == null || flag;
    }
}
