package cn.nine.pros.post.client.model.out;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "明信片详情")
public class PostcardDetailVO {

    @Schema(description = "明信片 ID")
    private Long id;

    @Schema(description = "正文")
    private String content;

    @Schema(description = "首张配图 URL（可空）")
    private String imageUrl;

    @Schema(description = "全部配图 URL（可空列表）")
    private List<String> imageUrls;

    @Schema(description = "发布时间")
    private LocalDateTime publishedAt;

    @Schema(description = "已通过审核的评论数")
    private Integer commentCount;

    @Schema(description = "作者")
    private PostcardAuthorVO author;

    @Schema(description = "审核状态：0 待审 1 通过 2 驳回（作者可见待审/驳回）")
    private Integer reviewStatus;

    @Schema(description = "当前用户是否为作者")
    private boolean owner;

    @Schema(description = "当前登录用户是否可向作者寄信（本人帖子为 false）")
    private Boolean canSendLetter;

    @Schema(description = "机审摘要（仅作者且已机审时返回）")
    private String machineReviewNote;
}
