package cn.nine.pros.post.client.model.out;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
@Schema(description = "App 国家信息")
public class AppCountryVO {

    @Schema(description = "国家代码（ISO 3166-1 alpha-2）")
    private String code;

    @Schema(description = "国家英文名")
    private String nameEn;

    @Schema(description = "国家中文名")
    private String nameZh;
}
