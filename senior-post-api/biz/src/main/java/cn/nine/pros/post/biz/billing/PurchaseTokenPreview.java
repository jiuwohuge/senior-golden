package cn.nine.pros.post.biz.billing;

import cn.nine.pros.post.biz.billing.util.PurchaseTokenHasher;

/**
 * purchaseToken 截断预览工具（日志/管理端）。
 */
public final class PurchaseTokenPreview {

    private PurchaseTokenPreview() {
    }

    /** first4…last4；过短则 ***。 */
    public static String truncate(String token) {
        return PurchaseTokenHasher.preview(token);
    }
}
