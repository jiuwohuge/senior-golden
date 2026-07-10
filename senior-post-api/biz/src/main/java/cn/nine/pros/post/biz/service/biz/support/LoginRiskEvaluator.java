package cn.nine.pros.post.biz.service.biz.support;

import cn.nine.pros.post.biz.model.domain.LoginDomain;
import cn.nine.pros.post.biz.support.GeoDistance;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.List;
import java.util.OptionalDouble;

/**
 * 异常登录规则（PRD §2.5）：满足 ≥2 项触发风险分级。
 */
public final class LoginRiskEvaluator {

    public static final int RISK_NONE = 0;
    public static final int RISK_LIGHT = 1;
    public static final int RISK_MEDIUM = 2;
    public static final int RISK_HIGH = 3;

    private static final ZoneId ZONE = ZoneId.of("Asia/Shanghai");

    private LoginRiskEvaluator() {
    }

    public record RiskResult(int level, int triggerCount) {
    }

    /**
     * @param prevSuccessLogins 最近成功登录（新→旧），可空
     * @param prevLat/prevLng   用户资料上一次坐标
     */
    public static RiskResult evaluate(
            String currentIpCountry,
            String currentDeviceUuid,
            Double currentLat,
            Double currentLng,
            List<LoginDomain> prevSuccessLogins,
            Double prevLat,
            Double prevLng) {
        int triggers = 0;
        LoginDomain last = (prevSuccessLogins == null || prevSuccessLogins.isEmpty())
                ? null
                : prevSuccessLogins.get(0);

        // IP 国家变化（双方均已知才计）
        if (last != null
                && StringUtils.hasText(last.getIpCountry())
                && StringUtils.hasText(currentIpCountry)
                && !last.getIpCountry().equalsIgnoreCase(currentIpCountry.trim())) {
            triggers++;
        }

        // 设备变化
        if (last != null
                && StringUtils.hasText(last.getDeviceUuid())
                && StringUtils.hasText(currentDeviceUuid)
                && !last.getDeviceUuid().equals(currentDeviceUuid.trim())) {
            triggers++;
        }

        // 登录时间异常：本地 02:00–05:00
        int hour = LocalDateTime.now(ZONE).getHour();
        if (hour >= 2 && hour < 5) {
            triggers++;
        }

        // 24h 内距离 > 1000km
        Double latA = currentLat != null ? currentLat : null;
        Double lonA = currentLng != null ? currentLng : null;
        Double latB = prevLat;
        Double lonB = prevLng;
        if (latA == null && last != null) {
            // 无当前坐标则无法用距离项
            latA = null;
        }
        OptionalDouble dist = GeoDistance.haversineKm(latA, lonA, latB, lonB);
        if (dist.isPresent() && dist.getAsDouble() > 1000.0) {
            if (last != null && last.getCreatedAt() != null
                    && last.getCreatedAt().isAfter(LocalDateTime.now().minusHours(24))) {
                triggers++;
            } else if (prevLat != null && prevLng != null && currentLat != null && currentLng != null) {
                // 资料坐标突变也计一次（无近期登录时）
                triggers++;
            }
        }

        int level = RISK_NONE;
        if (triggers >= 4) {
            level = RISK_HIGH;
        } else if (triggers >= 3) {
            level = RISK_MEDIUM;
        } else if (triggers >= 2) {
            level = RISK_LIGHT;
        }
        return new RiskResult(level, triggers);
    }
}
