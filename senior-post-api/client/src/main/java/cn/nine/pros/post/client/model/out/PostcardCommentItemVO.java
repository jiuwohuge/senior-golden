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
@Schema(description = "明信片评论项（待审/已通过均返回正文；驳回的不进入列表）")
public class PostcardCommentItemVO {

    @Schema(description = "评论 ID")
    private Long id;

    @Schema(description = "正文")
    private String content;

    @Schema(description = "创建时间")
    private LocalDateTime createdAt;

    @Schema(description = "作者")
    private PostcardAuthorVO author;
}
