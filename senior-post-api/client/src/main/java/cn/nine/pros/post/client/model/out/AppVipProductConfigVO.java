package cn.nine.pros.post.client.model.out;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Data;

/**
 * App 可读的 VIP 产品展示配置（来自 {@code sys_config} {@code vip} 分组，不含用户订阅态）。
 */
@Data
@Builder
@Schema(description = "VIP 产品展示配置（与后台 VipConfig 分组一致）")
public class AppVipProductConfigVO {

    @Schema(description = "是否展示 VIP 入口/营销（vip.product.enabled）")
    private boolean productEnabled;

    @Schema(description = "对外名称（vip.product.display_name）")
    private String displayName;

    @Schema(description = "英文卖点（vip.product.tagline）")
    private String tagline;

    @Schema(description = "中文卖点（vip.product.tagline_zh）")
    private String taglineZh;

    @Schema(description = "VIP 平邮剩余小时占位（vip.benefit.standard_delivery_hours，0 表示由业务即时策略）")
    private int standardDeliveryHours;
}
