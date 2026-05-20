package cn.nine.pros.post.client.common.constant;

/**
 * {@code bu_user.gender}：0 未设置，1 男，2 女，3 其他/不愿透露。
 */
public final class UserGender {

    public static final int UNSPECIFIED = 0;
    public static final int MALE = 1;
    public static final int FEMALE = 2;
    public static final int OTHER = 3;

    private UserGender() {
    }

    public static boolean isValidForProfile(int code) {
        return code >= MALE && code <= OTHER;
    }
}
