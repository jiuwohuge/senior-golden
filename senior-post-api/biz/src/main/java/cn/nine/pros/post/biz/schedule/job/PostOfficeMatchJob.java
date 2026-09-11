package cn.nine.pros.post.biz.schedule.job;

import cn.nine.pros.post.biz.service.biz.PostOfficeMatchService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

/**
 * POST_OFFICE 匹配池 drain 与超时审核放行。
 */
@Component
@RequiredArgsConstructor
public class PostOfficeMatchJob {

    private final PostOfficeMatchService postOfficeMatchService;

    /** 以当前时刻为基准跑一轮匹配批次。 */
    public void run() {
        postOfficeMatchService.runMatchBatch(LocalDateTime.now());
    }
}
