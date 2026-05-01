package cn.nine.pros.post.client.model.out;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
@Schema(description = "App 启动配置")
public class AppBootstrapVO {

    @Schema(description = "注册最小年龄")
    private Integer minRegisterAge;

    @Schema(description = "国家列表")
    private List<AppCountryVO> countries;
}
