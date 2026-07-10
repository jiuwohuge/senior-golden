package cn.nine.pros.post.biz.service.biz.support;

import cn.nine.pros.post.biz.service.biz.GeoIpService;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;

/**
 * 基于 ip-api.com 的轻量 GeoIP（开发/M1 务实版；失败降级为空）。
 */
@Slf4j
@Service
public class HttpGeoIpService implements GeoIpService {

    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(2))
            .build();
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public GeoIpLookup resolve(String ip) {
        if (!StringUtils.hasText(ip) || isPrivateOrLocal(ip.trim())) {
            return GeoIpLookup.empty();
        }
        String trimmed = ip.trim();
        try {
            HttpRequest req = HttpRequest.newBuilder()
                    .uri(URI.create("http://ip-api.com/json/" + trimmed + "?fields=status,countryCode,city,lat,lon"))
                    .timeout(Duration.ofSeconds(2))
                    .GET()
                    .build();
            HttpResponse<String> res = httpClient.send(req, HttpResponse.BodyHandlers.ofString());
            if (res.statusCode() != 200 || res.body() == null) {
                log.warn("geoip http status={}, ip={}", res.statusCode(), trimmed);
                return GeoIpLookup.empty();
            }
            JsonNode root = objectMapper.readTree(res.body());
            if (!"success".equalsIgnoreCase(root.path("status").asText())) {
                return GeoIpLookup.empty();
            }
            String cc = textOrNull(root, "countryCode");
            String city = textOrNull(root, "city");
            Double lat = root.hasNonNull("lat") ? root.get("lat").asDouble() : null;
            Double lon = root.hasNonNull("lon") ? root.get("lon").asDouble() : null;
            return new GeoIpLookup(cc, city, lat, lon);
        } catch (Exception e) {
            log.warn("geoip resolve failed, ip={}: {}", trimmed, e.toString());
            return GeoIpLookup.empty();
        }
    }

    @Override
    public GeoIpLookup reverseFromLatLng(Double latitude, Double longitude) {
        if (latitude == null || longitude == null) {
            return GeoIpLookup.empty();
        }
        if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
            return GeoIpLookup.empty();
        }
        try {
            String url = "https://api.bigdatacloud.net/data/reverse-geocode-client"
                    + "?latitude=" + latitude
                    + "&longitude=" + longitude
                    + "&localityLanguage=en";
            HttpRequest req = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .timeout(Duration.ofSeconds(3))
                    .GET()
                    .build();
            HttpResponse<String> res = httpClient.send(req, HttpResponse.BodyHandlers.ofString());
            if (res.statusCode() != 200 || res.body() == null) {
                log.warn("reverse geocode http status={}", res.statusCode());
                return GeoIpLookup.empty();
            }
            JsonNode root = objectMapper.readTree(res.body());
            String cc = textOrNull(root, "countryCode");
            String city = textOrNull(root, "city");
            if (!StringUtils.hasText(city)) {
                city = textOrNull(root, "locality");
            }
            return new GeoIpLookup(cc, city, latitude, longitude);
        } catch (Exception e) {
            log.warn("reverse geocode failed, lat={}, lng={}: {}", latitude, longitude, e.toString());
            return GeoIpLookup.empty();
        }
    }

    private static String textOrNull(JsonNode root, String field) {
        String v = root.path(field).asText(null);
        return StringUtils.hasText(v) ? v.trim() : null;
    }

    private static boolean isPrivateOrLocal(String ip) {
        return "127.0.0.1".equals(ip)
                || "::1".equals(ip)
                || "localhost".equalsIgnoreCase(ip)
                || ip.startsWith("10.")
                || ip.startsWith("192.168.")
                || ip.startsWith("172.16.")
                || ip.startsWith("172.17.")
                || ip.startsWith("172.18.")
                || ip.startsWith("172.19.")
                || ip.startsWith("172.2")
                || ip.startsWith("172.3");
    }
}
