package cn.nine.pros.post.client.common.constant;

/**
 * §14 行为事件类型常量。
 */
public final class BehaviorActionTypes {

    public static final String SEND_LETTER = "send_letter";
    public static final String OPEN_LETTER = "open_letter";
    public static final String REPLY_LETTER = "reply_letter";
    public static final String LOGIN = "login";

    public static final String ADD_PENPAL_REQUEST = "add_penpal_request";
    public static final String ACCEPT_PENPAL = "accept_penpal";
    public static final String REJECT_PENPAL = "reject_penpal";
    public static final String VIEW_RECOMMENDATION = "view_recommendation";
    public static final String WRITE_FROM_RECOMMENDATION = "write_from_recommendation";

    public static final String TARGET_LETTER = "letter";
    public static final String TARGET_USER = "user";

    private BehaviorActionTypes() {
    }
}
