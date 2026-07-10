package cn.nine.pros.post.client.model.out;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PenpalListItemVO {

    private Long peerUserId;
    private String nickname;
    private String avatarUrl;
    private String countryCode;
    private Integer letterCount;
    private Integer penpalDays;
    private LocalDateTime penpalSince;
}
