package cn.nine.pros.post.biz.error;

/**
 * Senior Post 应用层业务错误码（4xxxxx 段，与《底层框架能力》4xx 业务约定一致）。
 * <p>
 * 客户端可对特定编码做统一交互（如跳转商城、会员开通页）。
 */
public final class PostAppErrorCodes {

    private PostAppErrorCodes() {}

    /**
     * 邮票余额不足以完成当前操作（挂号寄信、平邮加速、提前拆信等）。
     */
    public static final int STAMP_INSUFFICIENT = 400301;

    /**
     * 需要会员身份方可使用（预留；具体接口在抛出时赋值文案）。
     */
    public static final int VIP_REQUIRED = 400302;
}
