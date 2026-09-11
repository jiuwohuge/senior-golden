package cn.nine.pros.post.client.model.input.admin;

import cn.nine.commons.data.dto.AbstractDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@Schema(description = "购买记录定位（purchaseId 或 purchaseNo 二选一）")
public class AdminCommercePurchaseIdInDto extends AbstractDTO {

    @Schema(description = "购买主单 ID")
    private Long purchaseId;

    @Schema(description = "内部购买号")
    private String purchaseNo;
}
