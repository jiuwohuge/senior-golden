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

    @Schema(description = "注册/登录前可选：按 lang 返回兴趣标签选项（与名录选项一致）")
    private List<InterestTagOptionVO> interestTagOptions;

    @Schema(description = "VIP 产品展示配置（匿名可读，与 Manage VipConfig 同源键）")
    private AppVipProductConfigVO vipProduct;
}
