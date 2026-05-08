package cn.nine.pros.post.biz.config;

import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Configuration
@EnableConfigurationProperties({TencentImProperties.class, OssProperties.class, SeniorPostAuthProperties.class})
public class PostBizConfiguration {
}
