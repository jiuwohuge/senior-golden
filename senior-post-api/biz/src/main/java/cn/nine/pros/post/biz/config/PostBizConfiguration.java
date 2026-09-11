package cn.nine.pros.post.biz.config;

import cn.nine.pros.post.biz.schedule.SchedulerProperties;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Configuration
@EnableConfigurationProperties({
        OssProperties.class,
        SeniorPostAuthProperties.class,
        ModerationProperties.class,
        TimeLetterProperties.class,
        PlusBillingProperties.class,
        SchedulerProperties.class
})
public class PostBizConfiguration {
}
