package cn.nine.pros.post.client.model.input.admin;

import cn.nine.commons.data.dto.AbstractDTO;
import cn.nine.commons.data.page.PageQuery;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.Valid;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

@Data
@EqualsAndHashCode(callSuper = true)
@Schema(description = "购买记录分页查询")
public class AdminCommercePurchaseQueryInDto extends AbstractDTO {

    @Valid
    private PageQuery page;

    private Long userId;
    private String purchaseNo;
    private Long productId;
    private String productCode;
    private String status;
    private LocalDateTime purchasedAtFrom;
    private LocalDateTime purchasedAtTo;
}
