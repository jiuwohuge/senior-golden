package cn.nine.pros.post.biz.error;

/**
 * Senior Post 应用层业务错误码（4xxxxx 段，与《底层框架能力》4xx 业务约定一致）。
 * <p>
 * 客户端可对特定编码做统一交互（如跳转会员开通页）。
 */
public final class PostAppErrorCodes {

    private PostAppErrorCodes() {}

    /**
     * 需要会员身份方可使用（预留；具体接口在抛出时赋值文案）。
     */
    public static final int VIP_REQUIRED = 400302;
}
