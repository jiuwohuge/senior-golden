package cn.nine.pros.post.biz.model.domain;

import cn.nine.commons.data.domain.AbstractAuditableDomain;
import cn.nine.pros.post.biz.support.mybatis.PostgresJsonbTypeHandler;
import cn.nine.pros.post.client.model.json.CommerceProductMetadata;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.ToString;

@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
@TableName(value = "bu_commerce_product", autoResultMap = true)
public class CommerceProductDomain extends AbstractAuditableDomain {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;

    @Schema(description = "商品编码")
    private String productCode;

    @Schema(description = "商品类型 skin|template|font|attachment|vip_bundle|export")
    private String productType;

    @Schema(description = "标题 i18n key")
    private String titleKey;

    @Schema(description = "价格（分）")
    private Integer priceCents;

    @TableField(value = "metadata_json", typeHandler = PostgresJsonbTypeHandler.class)
    private CommerceProductMetadata metadataJson;

    private Integer sortOrder;

    /** 1=上架 */
    private Integer status;
}
