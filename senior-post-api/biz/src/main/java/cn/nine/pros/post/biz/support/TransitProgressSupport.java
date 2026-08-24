package cn.nine.pros.post.biz.support;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;

/** Authoritative server-side progress for a letter's sent-to-arrival window. */
public final class TransitProgressSupport {

    private TransitProgressSupport() {
    }

    public static Double ratio(LocalDateTime sent, LocalDateTime eta, LocalDateTime now) {
        if (sent == null || eta == null || now == null || !eta.isAfter(sent)) {
            return null;
        }
        long total = ChronoUnit.MINUTES.between(sent, eta);
        if (total <= 0) {
            return null;
        }
        long done = ChronoUnit.MINUTES.between(sent, now);
        return Math.min(1.0, Math.max(0.0, (double) done / (double) total));
    }
}
