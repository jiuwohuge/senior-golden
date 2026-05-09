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
@Schema(description = "明信片墙列表项（仅审核通过且公开）")
public class PostcardWallItemVO {

    @Schema(description = "明信片 ID")
    private Long id;

    @Schema(description = "正文")
    private String content;

    @Schema(description = "首张配图 URL（可空，与 imageUrls 首项一致）")
    private String imageUrl;

    @Schema(description = "全部配图 URL（可空列表）")
    private List<String> imageUrls;

    @Schema(description = "发布时间")
    private LocalDateTime publishedAt;

    @Schema(description = "已通过审核的评论数")
    private Integer commentCount;

    @Schema(description = "作者")
    private PostcardAuthorVO author;

    @Schema(description = "审核状态：0待审 1通过 2驳回（「我的明信片」流水返回；墙列表可为空）")
    private Integer reviewStatus;

    @Schema(description = "内容状态：1公开 2隐藏 3违规删除（「我的明信片」流水返回；墙列表可为空）")
    private Integer postStatus;
}
