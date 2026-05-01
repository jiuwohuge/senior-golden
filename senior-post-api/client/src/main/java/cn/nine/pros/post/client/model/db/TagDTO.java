package cn.nine.pros.post.client.model.db;

import cn.nine.commons.data.dto.AbstractAuditableDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

/**
 * 兴趣标签表 DTO
 *
 * @author Administrator
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
public class TagDTO extends AbstractAuditableDTO {

    private static final long serialVersionUID = 1L;

    /**
     * 标签ID
     */
    @Schema(description = "标签ID")
    private Integer id;
    /**
     * 标签名称
     */
    @Schema(description = "标签名称")
    private String tagName;
    /**
     * 语言代码（en/zh/ja/ko等）
     */
    @Schema(description = "语言代码（en/zh/ja/ko等）")
    private String langCode;
    /**
     * 排序顺序
     */
    @Schema(description = "排序顺序")
    private Integer sortOrder;

}