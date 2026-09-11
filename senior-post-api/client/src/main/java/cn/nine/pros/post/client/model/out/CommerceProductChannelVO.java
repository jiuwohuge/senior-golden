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
@Schema(description = "商品渠道映射")
public class CommerceProductChannelVO {

    private Long id;
    private Long productId;
    private String provider;
    private String storeProductId;
    private String basePlanId;
    private String offerId;
    private String appIdOrPackageName;
    private String environment;
    private Integer status;
    private Object providerConfigJson;
}
