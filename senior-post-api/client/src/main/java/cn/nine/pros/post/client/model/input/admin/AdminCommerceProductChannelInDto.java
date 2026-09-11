package cn.nine.pros.post.client.model.input.admin;

import cn.nine.commons.data.dto.AbstractDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@Schema(description = "商品渠道保存项")
public class AdminCommerceProductChannelInDto extends AbstractDTO {

    @Schema(description = "渠道行 ID（更新时传入）")
    private Long id;

    @NotBlank
    @Schema(description = "google_play|apple_app_store|mock")
    private String provider;

    @NotBlank
    @Schema(description = "商店商品 ID")
    private String storeProductId;

    @Schema(description = "Play basePlanId")
    private String basePlanId;

    @Schema(description = "Play offerId")
    private String offerId;

    @Schema(description = "包名 / App ID")
    private String appIdOrPackageName;

    @NotBlank
    @Schema(description = "sandbox|production")
    private String environment;

    @Schema(description = "1=启用")
    private Integer status;

    @Schema(description = "渠道扩展 JSON")
    private Object providerConfigJson;
}
