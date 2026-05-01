package cn.nine.pros.post.client.model.input.admin;

import cn.nine.commons.data.dto.AbstractDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@Schema(description = "国家/地区保存入参")
public class CountryInDto extends AbstractDTO {

    @Schema(description = "主键（更新时传入）")
    private Integer id;

    @NotBlank(message = "国家代码不能为空")
    @Schema(description = "ISO 3166-1 alpha-2")
    private String countryCode;

    @NotBlank(message = "英文名称不能为空")
    @Schema(description = "英文名称")
    private String countryNameEn;

    @NotBlank(message = "中文名称不能为空")
    @Schema(description = "中文名称")
    private String countryNameZh;

    @Schema(description = "排序，越小越靠前")
    private Integer sortOrder;
}
