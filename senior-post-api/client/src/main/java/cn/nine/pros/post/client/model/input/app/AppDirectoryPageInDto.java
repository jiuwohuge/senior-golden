package cn.nine.pros.post.client.model.input.app;

import cn.nine.commons.data.page.PageQuery;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.util.List;

@Data
@Schema(description = "通信名录分页查询")
public class AppDirectoryPageInDto {

    @Schema(description = "分页参数")
    private PageQuery page;

    @Schema(description = "国家代码（可空）")
    private String countryCode;

    @Schema(description = "最小年龄（含）")
    private Integer minAge;

    @Schema(description = "最大年龄（含）")
    private Integer maxAge;

    @Schema(description = "兴趣标签名（与 sys_tag.tag_name 匹配，AND 关系；可空）")
    private List<String> interestNames;
}
