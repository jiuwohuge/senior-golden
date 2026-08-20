package cn.nine.pros.post.client.common.constant;

/**
 * 邮局首页主 CTA，由管理后台写入 {@code home.recommended_action}。
 */
public final class HomeRecommendedAction {

    public static final String TIME_LETTER = "TIME_LETTER";
    public static final String POST_OFFICE = "POST_OFFICE";
    public static final String CONFIG_KEY = "home.recommended_action";
    public static final String CONFIG_GROUP = "home";

    private HomeRecommendedAction() {
    }

    /**
     * 非法或空值回落到时光信，避免 App 空白主按钮。
     */
    public static String normalize(String raw) {
        if (raw != null && POST_OFFICE.equalsIgnoreCase(raw.trim())) {
            return POST_OFFICE;
        }
        return TIME_LETTER;
    }
}
