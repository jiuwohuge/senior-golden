package cn.nine.pros.post.client.common.constant;

/**
 * {@code bu_user.gender}：0 未设置，1 男，2 女。
 * 历史库中可能存在 3（已废弃），新写入仅允许 1/2。
 */
public final class UserGender {

    public static final int UNSPECIFIED = 0;
    public static final int MALE = 1;
    public static final int FEMALE = 2;

    /** @deprecated 历史遗留值，不再接受新资料写入 */
    @Deprecated
    public static final int OTHER = 3;

    private UserGender() {
    }

    public static boolean isValidForProfile(int code) {
        return code == MALE || code == FEMALE;
    }
}
