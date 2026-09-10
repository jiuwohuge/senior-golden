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
@Schema(description = "Plus SKU 展示项")
public class PlusSkuItemVO {

    @Schema(description = "商品 ID：plus_monthly | plus_yearly")
    private String productId;

    @Schema(description = "是否主推（年订优先）")
    private Boolean preferred;
}
