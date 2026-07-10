package cn.nine.pros.post.client.model.out;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProfileOverviewVO {

    @Schema(description = "笔友数量")
    private Integer penpalCount;

    @Schema(description = "有效通信信件数")
    private Integer letterCount;

    @Schema(description = "时光信数量（不含草稿）")
    private Integer timeLetterCount;
}
