package cn.nine.pros.post.biz.service.push;

/**
 * 信件推送事件常量与文案（禁止支付类事件）。
 */
public final class NotificationEventTypes {

    public static final String LETTER_MATCHED_IN_TRANSIT = "letter_matched_in_transit";
    public static final String LETTER_ARRIVED = "letter_arrived";

    public static final String TITLE_IN_TRANSIT = "一封信正在路上。";
    public static final String BODY_IN_TRANSIT = "一封信正在路上。";
    public static final String TITLE_ARRIVED = "一封信已经送达，请查收。";
    public static final String BODY_ARRIVED = "一封信已经送达，请查收。";

    public static final String SCREEN_IN_TRANSIT = "in_transit";
    public static final String SCREEN_ARRIVED = "arrived";

    private NotificationEventTypes() {
    }

    public static boolean isAllowedLetterType(String eventType) {
        return LETTER_MATCHED_IN_TRANSIT.equals(eventType) || LETTER_ARRIVED.equals(eventType);
    }

    /**
     * 支付/订阅类事件（精确或前缀）一律禁止入队。
     */
    public static boolean isPaymentLike(String eventType) {
        if (eventType == null || eventType.isBlank()) {
            return false;
        }
        String t = eventType.trim().toLowerCase();
        if (t.startsWith("subscription_") || t.startsWith("billing_") || t.startsWith("payment_")) {
            return true;
        }
        return switch (t) {
            case "purchase_success", "renew", "charge_fail", "cancel", "refund", "revoke" -> true;
            default -> t.contains("purchase") || t.contains("refund") || t.contains("subscription")
                    || t.contains("billing") || t.contains("payment") || t.contains("charge");
        };
    }

    public static String dedupeKey(String eventType, long letterId, long recipientUserId) {
        if (LETTER_MATCHED_IN_TRANSIT.equals(eventType)) {
            return "letter_matched:" + letterId + ":" + recipientUserId;
        }
        if (LETTER_ARRIVED.equals(eventType)) {
            return "letter_arrived:" + letterId + ":" + recipientUserId;
        }
        return eventType + ":" + letterId + ":" + recipientUserId;
    }
}
