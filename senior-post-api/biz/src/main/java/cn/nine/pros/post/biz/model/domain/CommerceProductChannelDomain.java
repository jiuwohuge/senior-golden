package cn.nine.pros.post.biz.model.domain;

import cn.nine.commons.data.domain.AbstractAuditableDomain;
import cn.nine.pros.post.biz.support.mybatis.PostgresJsonbTypeHandler;
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

/**
 * 商品渠道映射：google_play / apple_app_store / mock × store_product_id。
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
@TableName(value = "bu_commerce_product_channel", autoResultMap = true)
public class CommerceProductChannelDomain extends AbstractAuditableDomain {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;

    @Schema(description = "内部商品 ID（bu_commerce_product.id）")
    private Long productId;

    @Schema(description = "google_play|apple_app_store|mock")
    private String provider;

    @Schema(description = "商店侧商品 ID")
    private String storeProductId;

    @Schema(description = "Play basePlanId")
    private String basePlanId;

    @Schema(description = "Play offerId")
    private String offerId;

    @Schema(description = "包名 / App ID")
    private String appIdOrPackageName;

    @Schema(description = "sandbox|production")
    private String environment;

    /** 1=启用 */
    private Integer status;

    @Schema(description = "渠道扩展 JSON")
    @TableField(value = "provider_config_json", typeHandler = PostgresJsonbTypeHandler.class)
    private Object providerConfigJson;
}
