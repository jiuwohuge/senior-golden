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
@Schema(description = "兴趣标签选项（名录筛选 / 资料编辑共用）")
public class InterestTagOptionVO {

    @Schema(description = "标签主键，对应 sys_tag.id")
    private Integer id;

    @Schema(description = "标签名称（与名录筛选 interestNames、sys_tag.tag_name 一致）")
    private String tagName;

    @Schema(description = "语言代码")
    private String langCode;
}
