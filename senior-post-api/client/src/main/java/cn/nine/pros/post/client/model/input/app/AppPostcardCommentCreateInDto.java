package cn.nine.pros.post.client.model.input.app;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
@Schema(description = "发表评论（待审核）")
public class AppPostcardCommentCreateInDto {

    @NotBlank
    @Size(max = 1000)
    @Schema(description = "评论正文")
    private String content;

    @Schema(description = "回复的评论ID，顶级评论不传")
    private Long parentCommentId;
}
