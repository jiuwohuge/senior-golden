package cn.nine.pros.post.biz.service.base;

/**
 * 登录赠票 / 发帖奖励（FP-A6-003）。
 */
public interface StampGrantService {

    /** 登录或注册成功后调用（同一 UTC 日仅首次生效）。 */
    void afterLogin(long userId);

    /** 发布明信片成功后调用（每张明信片至多奖励一次；受每日发帖邮票上限约束）。 */
    void afterPostcardCreated(long userId, long postcardId);
}
