package cn.nine.pros.post.client.model.db;

import cn.nine.commons.data.dto.AbstractAuditableDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

/**
 * 国家地区表 DTO
 *
 * @author Administrator
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
public class CountryDTO extends AbstractAuditableDTO {

    private static final long serialVersionUID = 1L;

    /**
     * 国家ID
     */
    @Schema(description = "国家ID")
    private Integer id;
    /**
     * 国家代码（ISO 3166-1 alpha-2）
     */
    @Schema(description = "国家代码（ISO 3166-1 alpha-2）")
    private String countryCode;
    /**
     * 英文名称
     */
    @Schema(description = "英文名称")
    private String countryNameEn;
    /**
     * 中文名称
     */
    @Schema(description = "中文名称")
    private String countryNameZh;
    /**
     * 排序顺序
     */
    @Schema(description = "排序顺序")
    private Integer sortOrder;

}