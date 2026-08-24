package cn.nine.pros.post.client.model.out;

import com.fasterxml.jackson.annotation.JsonProperty;
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

    @Schema(description = "写信主题邮票选项（按请求语言；客户端只渲染下发列表）")
    private List<LetterTopicOptionVO> letterTopicOptions;

    @Schema(description = "VIP 产品展示配置（匿名可读，与 Manage VipConfig 同源键）")
    private AppVipProductConfigVO vipProduct;

    @Schema(description = "每日可创建时光信配额（sys_config letter.daily_quota，默认 5）")
    @JsonProperty("dailyLetterQuota")
    private Integer dailyLetterQuota;
}
