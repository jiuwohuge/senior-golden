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
@Schema(description = "管理端反馈列表项")
public class AppFeedbackAdminItemVO {

    private Long id;
    private Long userId;
    private String nickname;
    private String content;
    private String clientVersion;
    private LocalDateTime createdAt;
}
