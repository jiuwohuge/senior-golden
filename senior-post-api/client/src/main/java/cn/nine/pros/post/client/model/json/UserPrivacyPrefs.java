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
 * 用户隐私偏好 privacy_json。
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonIgnoreProperties(ignoreUnknown = true)
@Schema(description = "隐私偏好")
public class UserPrivacyPrefs {

    @JsonProperty("hide_recommendations")
    @JsonAlias({"hideRecommendations"})
    @Schema(description = "隐藏每日推荐")
    private Boolean hideRecommendations;

    @JsonProperty("reject_stranger_letters")
    @JsonAlias({"rejectStrangerLetters", "rejectStrangerMail"})
    @Schema(description = "拒收陌生邮局信")
    private Boolean rejectStrangerLetters;

    public void mergeFrom(UserPrivacyPrefs patch) {
        if (patch == null) {
            return;
        }
        if (patch.hideRecommendations != null) {
            this.hideRecommendations = patch.hideRecommendations;
        }
        if (patch.rejectStrangerLetters != null) {
            this.rejectStrangerLetters = patch.rejectStrangerLetters;
        }
    }

    public boolean hideRecommendationsOrFalse() {
        return Boolean.TRUE.equals(hideRecommendations);
    }

    public boolean rejectStrangerLettersOrFalse() {
        return Boolean.TRUE.equals(rejectStrangerLetters);
    }
}
