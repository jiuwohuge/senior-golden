package cn.nine.pros.post.biz.model.domain;

import cn.nine.commons.data.domain.AbstractAuditableDomain;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

/**
 * 国家地区表 Domain
 *
 * @author Administrator
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
@TableName("sys_country")
public class CountryDomain extends AbstractAuditableDomain {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
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