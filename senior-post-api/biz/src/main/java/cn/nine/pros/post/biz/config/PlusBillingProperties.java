package cn.nine.pros.post.biz.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * Plus / Play Billing 配置（配额、包名、测试覆盖开关）。
 * <p>play-public-key 仅占位；生产须接入 Google Play Developer API，勿在代码中发明密钥。
 */
@Data
@ConfigurationProperties(prefix = "senior-post.plus")
public class PlusBillingProperties {

    /** 非订阅用户 AI 助手每周免费次数。 */
    private int aiFreeWeeklyQuota = 3;

    /** 订阅/试用用户 AI 助手每周配额。 */
    private int aiSubscriberWeeklyQuota = 100;

    /** 在途撤回/改信窗口（分钟）。 */
    private int inTransitRecallWindowMinutes = 20;

    /** Play 应用包名；校验时与客户端上报比对。 */
    private String playPackageName = "cn.nine.pros.seniorpost";

    /**
     * Play 公钥占位。为空时 verify 仅做结构化校验（token 非空且长度≥8）。
     * TODO(prod): 接入 Google Play Developer API 校验订阅真实性。
     */
    private String playPublicKey = "";

    /** 是否开放 /api/billing/test-override（本地/分身侧）。 */
    private boolean testOverrideEnabled = true;
}
