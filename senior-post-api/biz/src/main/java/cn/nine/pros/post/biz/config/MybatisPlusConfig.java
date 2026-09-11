package cn.nine.pros.post.biz.config;

import com.baomidou.mybatisplus.annotation.DbType;
import com.baomidou.mybatisplus.extension.plugins.inner.PaginationInnerInterceptor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * 注册 MyBatis-Plus 分页拦截器，供 Boot 自动装配进 {@code MybatisPlusInterceptor}。
 * <p>MP 3.5.9+ 需额外依赖 {@code mybatis-plus-jsqlparser}；否则 {@code page()} 能查出 records，
 * 但 {@code Page#getTotal()} 恒为 0（管理端反馈列表等表现为 total/pages=0）。
 */
@Configuration
public class MybatisPlusConfig {

    @Bean
    public PaginationInnerInterceptor paginationInnerInterceptor() {
        return new PaginationInnerInterceptor(DbType.POSTGRE_SQL);
    }
}
