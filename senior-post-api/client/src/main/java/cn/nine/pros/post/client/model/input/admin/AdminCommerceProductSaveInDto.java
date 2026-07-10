package cn.nine.pros.post.client.model.input.admin;

import cn.nine.commons.data.dto.AbstractDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.util.Map;

@Data
@EqualsAndHashCode(callSuper = true)
@Schema(description = "商业商品保存")
public class AdminCommerceProductSaveInDto extends AbstractDTO {

    @Schema(description = "商品 ID（更新时传入）")
    private Long id;

    @NotBlank
    @Schema(description = "商品编码")
    private String productCode;

    @NotBlank
    @Schema(description = "商品类型")
    private String productType;

    @NotBlank
    @Schema(description = "标题 i18n key")
    private String titleKey;

    @Schema(description = "价格（分）")
    private Integer priceCents;

    @Schema(description = "元数据 JSON")
    private Map<String, Object> metadataJson;

    @Schema(description = "排序")
    private Integer sortOrder;

    @Schema(description = "状态 1=上架")
    private Integer status;
}
