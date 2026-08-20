package cn.nine.pros.post.biz.service.biz.support;

import java.util.concurrent.ThreadLocalRandom;

/**
 * 静默 guest 的展示资料：随机昵称、按语言推断国家。不写库。
 */
public final class GuestProfileSupport {

    private static final String[] ZH_NICKS = {
            "青松", "晚风", "信笺", "渡口", "暖阳", "纸鸢", "旧巷", "南窗", "闲云", "晨露",
            "归舟", "灯火", "秋水", "远山", "书香"
    };

    private static final String[] EN_NICKS = {
            "Cedar", "Harbor", "Letter", "Willow", "Ember", "Quill", "Maple", "Lumen", "Cove", "Pine"
    };

    private GuestProfileSupport() {
    }

    /** 语言向昵称：中文池或英文池，加三位数字避免撞名。 */
    public static String randomNickname(String languageTag) {
        boolean zh = languageTag != null && languageTag.toLowerCase().startsWith("zh");
        String[] pool = zh ? ZH_NICKS : EN_NICKS;
        String base = pool[ThreadLocalRandom.current().nextInt(pool.length)];
        int suffix = ThreadLocalRandom.current().nextInt(100, 1000);
        return base + suffix;
    }

    /**
     * 定位失败时的国家：客户端代码优先，否则语言（zh→CN，en→US），产品默认 CN。
     */
    public static String fallbackCountryCode(String clientCountryCode, String languageTag) {
        if (clientCountryCode != null && !clientCountryCode.isBlank()) {
            return clientCountryCode.trim().toUpperCase();
        }
        if (languageTag == null || languageTag.isBlank()) {
            return "CN";
        }
        String lang = languageTag.trim().toLowerCase();
        if (lang.startsWith("zh")) {
            return "CN";
        }
        if (lang.startsWith("en")) {
            return "US";
        }
        if (lang.startsWith("ja")) {
            return "JP";
        }
        if (lang.startsWith("ko")) {
            return "KR";
        }
        return "CN";
    }
}
