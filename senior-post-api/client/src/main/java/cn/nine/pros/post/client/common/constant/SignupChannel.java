package cn.nine.pros.post.client.common.constant;

/**
 * {@code bu_user.signup_channel} 开户方式。绑定升级不改此值。
 */
public final class SignupChannel {

    public static final String GUEST = "guest";
    public static final String EMAIL = "email";
    public static final String GOOGLE = "google";

    private SignupChannel() {
    }

    public static String normalize(String raw) {
        if (raw == null || raw.isBlank()) {
            return GUEST;
        }
        return raw.trim().toLowerCase();
    }

    public static boolean isGuest(String raw) {
        return GUEST.equals(normalize(raw));
    }
}
