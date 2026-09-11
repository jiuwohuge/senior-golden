package cn.nine.pros.post.biz.schedule;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Component;

import java.time.Duration;

/**
 * 基于 Redis SET NX EX 的轻量分布式任务锁，避免多实例重复执行同一 tick。
 * <p>tryLock 遇 Redis 异常 fail-closed（返回 false，跳过本轮）。
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class DistributedJobLock {

    private static final String KEY_PREFIX = "schedule:lock:";
    private static final String LOCK_VALUE = "1";

    private final StringRedisTemplate stringRedisTemplate;

    /**
     * 尝试获取任务锁。
     *
     * @param jobName 任务名（写入锁 key）
     * @param ttlMs   锁过期毫秒；须大于典型执行时间
     * @return true 表示本实例持有锁
     */
    public boolean tryLock(String jobName, long ttlMs) {
        String key = KEY_PREFIX + jobName;
        try {
            Boolean ok = stringRedisTemplate.opsForValue()
                    .setIfAbsent(key, LOCK_VALUE, Duration.ofMillis(Math.max(1L, ttlMs)));
            return Boolean.TRUE.equals(ok);
        } catch (RuntimeException e) {
            log.warn("schedule lock tryLock failed (fail-closed), job={}, err={}", jobName, e.getMessage());
            return false;
        }
    }

    /**
     * 释放任务锁；失败仅记日志，不抛出。
     */
    public void unlock(String jobName) {
        String key = KEY_PREFIX + jobName;
        try {
            stringRedisTemplate.delete(key);
        } catch (RuntimeException e) {
            log.warn("schedule lock unlock ignored error, job={}, err={}", jobName, e.getMessage());
        }
    }
}
