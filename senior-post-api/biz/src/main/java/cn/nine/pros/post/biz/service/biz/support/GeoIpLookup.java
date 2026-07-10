package cn.nine.pros.post.biz.service.biz.support;

/**
 * IP 地理解析结果；字段均可为 null（未知时不参与风控误伤）。
 */
public record GeoIpLookup(String countryCode, String city, Double latitude, Double longitude) {

    public static GeoIpLookup empty() {
        return new GeoIpLookup(null, null, null, null);
    }

    public boolean hasCountry() {
        return countryCode != null && !countryCode.isBlank();
    }
}
