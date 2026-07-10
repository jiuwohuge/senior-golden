package cn.nine.pros.post.biz.support;

import java.util.OptionalDouble;

/**
 * 地理距离工具（PRD §3.4 Haversine）。
 * 无坐标时投递侧应使用 {@link #DEFAULT_DELIVERY_DAYS_WHEN_NO_COORDS} 兜底。
 */
public final class GeoDistance {

    /** 无经纬度时延迟上限兜底（天） */
    public static final double DEFAULT_DELIVERY_DAYS_WHEN_NO_COORDS = 2.0;

    private static final double EARTH_RADIUS_KM = 6371.0;

    private GeoDistance() {
    }

    /**
     * Haversine 球面距离（公里）。任一坐标缺失则返回 empty。
     */
    public static OptionalDouble haversineKm(Double lat1, Double lon1, Double lat2, Double lon2) {
        if (lat1 == null || lon1 == null || lat2 == null || lon2 == null) {
            return OptionalDouble.empty();
        }
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLon / 2) * Math.sin(dLon / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return OptionalDouble.of(EARTH_RADIUS_KM * c);
    }
}
