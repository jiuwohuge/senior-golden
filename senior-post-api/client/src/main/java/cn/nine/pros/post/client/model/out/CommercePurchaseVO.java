package cn.nine.pros.post.client.model.out;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "购买记录（只读，token 仅预览）")
public class CommercePurchaseVO {

    private Long id;
    private String purchaseNo;
    private Long userId;
    private Long productId;
    private String productCode;
    private String provider;
    private String storeProductId;
    /** 单向掩码预览，从不返回完整 token / hash / cipher */
    private String purchaseTokenPreview;
    private String externalOrderId;
    private String status;
    private LocalDateTime purchasedAt;
    private LocalDateTime paidAt;
    private String environment;
    private Object channelSnapshotJson;
    private LocalDateTime createdAt;
}
