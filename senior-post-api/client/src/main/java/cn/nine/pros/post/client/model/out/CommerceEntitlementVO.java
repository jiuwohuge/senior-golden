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
@Schema(description = "用户商业权益")
public class CommerceEntitlementVO {

    private Long entitlementId;
    private Long productId;
    private String productCode;
    private String productType;
    private String titleKey;
    private String source;
    private LocalDateTime expiresAt;
    private LocalDateTime grantedAt;
}
