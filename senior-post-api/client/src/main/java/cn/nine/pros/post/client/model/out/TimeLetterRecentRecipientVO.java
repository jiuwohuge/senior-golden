package cn.nine.pros.post.client.model.out;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
@Schema(description = "最近收信人")
public class TimeLetterRecentRecipientVO {

    private Long userId;
    private String nickname;
    private String avatarUrl;
    private String countryLabel;
}
