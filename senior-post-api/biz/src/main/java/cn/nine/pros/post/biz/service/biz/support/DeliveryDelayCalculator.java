package cn.nine.pros.post.biz.service.biz.support;

import cn.nine.pros.post.biz.service.base.ConfigService;
import cn.nine.pros.post.biz.service.base.FriendshipService;
import cn.nine.pros.post.biz.support.GeoDistance;
import cn.nine.pros.post.client.model.db.UserDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.OptionalDouble;
import java.util.concurrent.ThreadLocalRandom;

/**
 * §6.1 投递延迟：base + 距离权重 + 关系权重 + 抖动，夹在 [min,max]；无坐标时按上限兜底。
 */
@Component
@RequiredArgsConstructor
public class DeliveryDelayCalculator {

    private static final String KEY_BASE = "delivery.delay_base_hours";
    private static final String KEY_MIN = "delivery.delay_min_hours";
    private static final String KEY_MAX = "delivery.delay_max_hours";
    private static final String KEY_DIST_MAX = "delivery.distance_max_km";

    private static final double DEFAULT_BASE_H = 6;
    private static final double DEFAULT_MIN_H = 2;
    private static final double DEFAULT_MAX_H = 48;
    private static final double DEFAULT_DIST_MAX_KM = 20_000;

    private final ConfigService configService;
    private final FriendshipService friendshipService;

    /**
     * 计算预计送达时间（now + delay）。
     *
     * @param from 发件人（需 lat/lng 若有）
     * @param to   收件人；POST_OFFICE 无收件人时传 null → 按上限兜底
     */
    public LocalDateTime expectedArrival(LocalDateTime now, UserDTO from, UserDTO to) {
        double minH = configService.getDouble(KEY_MIN, DEFAULT_MIN_H);
        double maxH = configService.getDouble(KEY_MAX, DEFAULT_MAX_H);
        if (maxH < minH) {
            maxH = minH;
        }
        double baseH = configService.getDouble(KEY_BASE, DEFAULT_BASE_H);
        double distMaxKm = configService.getDouble(KEY_DIST_MAX, DEFAULT_DIST_MAX_KM);

        double hours;
        if (to == null) {
            // 无收件人坐标：按上限兜底（PRD：无法获取位置时默认 2 天）
            hours = maxH;
        } else {
            hours = computeHoursWithRecipient(from, to, baseH, minH, maxH, distMaxKm);
        }
        hours = Math.max(minH, Math.min(maxH, hours));
        long minutes = Math.max(1L, Math.round(hours * 60.0));
        return now.plus(Duration.ofMinutes(minutes));
    }

    private double computeHoursWithRecipient(
            UserDTO from, UserDTO to, double baseH, double minH, double maxH, double distMaxKm) {
        OptionalDouble distKm = GeoDistance.haversineKm(
                from != null ? from.getLatitude() : null,
                from != null ? from.getLongitude() : null,
                to.getLatitude(),
                to.getLongitude());
        if (distKm.isEmpty()) {
            return maxH;
        }
        double distRatio = Math.min(1.0, Math.max(0.0, distKm.getAsDouble() / Math.max(1.0, distMaxKm)));
        // 距离权重：最多占 (max-min) 的 70%
        double distanceWeight = distRatio * (maxH - minH) * 0.7;
        boolean friends = from != null
                && from.getId() != null
                && to.getId() != null
                && friendshipService.areActiveFriends(from.getId(), to.getId());
        // 笔友：向区间下限靠拢（减半距离权重并略减基础）
        double relationshipWeight = friends ? -(maxH - minH) * 0.25 : 0;
        double jitter = ThreadLocalRandom.current().nextDouble(-0.5, 0.5);
        return baseH + distanceWeight + relationshipWeight + jitter;
    }
}
