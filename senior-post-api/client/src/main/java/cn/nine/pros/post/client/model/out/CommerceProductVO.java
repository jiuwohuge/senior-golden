package cn.nine.pros.post.client.model.out;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "商业商品")
public class CommerceProductVO {

    private Long id;
    private String productCode;
    private String productType;
    private String titleKey;
    private Integer priceCents;
    private Map<String, Object> metadataJson;
    private Integer sortOrder;
    private Integer status;
    private Boolean owned;
}
