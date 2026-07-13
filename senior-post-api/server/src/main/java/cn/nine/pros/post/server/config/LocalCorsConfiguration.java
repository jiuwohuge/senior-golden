package cn.nine.pros.post.server.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;

import java.util.List;

/**
 * local 环境 CORS：允许 Flutter Web（localhost 任意端口）联调 API。
 * 正式发版仍以 Android 为主；本配置仅服务本地多开浏览器测试，勿用于生产 profile。
 */
@Configuration
@Profile("local")
public class LocalCorsConfiguration {

    private static final Logger log = LoggerFactory.getLogger(LocalCorsConfiguration.class);

    /**
     * 最高优先级处理预检 OPTIONS，避免被后续鉴权过滤器拦截。
     */
    @Bean
    @Order(Ordered.HIGHEST_PRECEDENCE)
    public CorsFilter localCorsFilter() {
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowCredentials(true);
        // Flutter web 开发服务器端口不固定（如 5xxxx）
        config.setAllowedOriginPatterns(List.of(
                "http://localhost:*",
                "http://127.0.0.1:*"
        ));
        config.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS", "HEAD"));
        config.setAllowedHeaders(List.of("*"));
        config.setExposedHeaders(List.of("*"));
        config.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        log.info("Local CORS enabled for Flutter Web (localhost / 127.0.0.1 any port)");
        return new CorsFilter(source);
    }
}
