package cn.nine.pros.post.biz.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * 登录赠票 / 发帖奖励与日上限（FP-A6-003）。日期统一 UTC。
 */
@Data
@ConfigurationProperties(prefix = "senior-post.stamps-grant")
public class StampGrantProperties {

    /** 每日登录赠送邮票是否启用 */
    private boolean loginEnabled = true;

    /** 每个 UTC 日登录赠送数量（≤0 则不赠送） */
    private int loginDailyAmount = 1;

    /** 发帖奖励是否启用 */
    private boolean postcardEnabled = true;

    /** 每发布一条明信片奖励邮票数 */
    private int postcardRewardPerPost = 1;

    /**
     * 每个 UTC 日内，通过发帖累计获得的邮票上限（按奖励数量累计；0 表示不限制）。
     */
    private int postcardDailyStampCap = 5;
}
