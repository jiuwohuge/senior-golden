package cn.nine.pros.post.server.filter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

/**
 * App / 管理端 HTTP 访问日志（方法、路径、状态、耗时）。便于与 Flutter 端 Dio 日志对照联调。
 */
@Slf4j
@Component
@Order(Ordered.LOWEST_PRECEDENCE - 10)
public class ApiRequestLogFilter extends OncePerRequestFilter {

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        String uri = request.getRequestURI();
        if (uri.startsWith("/actuator")) {
            return true;
        }
        if (uri.startsWith("/webjars") || uri.startsWith("/swagger") || uri.startsWith("/v3/api-docs")
                || uri.startsWith("/doc.html") || uri.startsWith("/favicon")) {
            return true;
        }
        return !(uri.startsWith("/api/") || uri.startsWith("/webapi/"));
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain) throws ServletException, IOException {
        long t0 = System.nanoTime();
        try {
            filterChain.doFilter(request, response);
        } finally {
            long ms = (System.nanoTime() - t0) / 1_000_000L;
            log.info("[HTTP] {} {} -> {} ({} ms)",
                    request.getMethod(),
                    request.getRequestURI(),
                    response.getStatus(),
                    ms);
        }
    }
}
