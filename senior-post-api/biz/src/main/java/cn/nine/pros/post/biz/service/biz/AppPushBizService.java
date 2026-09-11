package cn.nine.pros.post.biz.service.biz;

import cn.nine.pros.post.client.model.input.app.PushMockEnqueueInDto;
import cn.nine.pros.post.client.model.out.PushMockEnqueueVO;

/**
 * App 推送业务（含 QA mock-enqueue）。
 */
public interface AppPushBizService {

    /**
     * Mock 入队信件推送；可选立即跑一轮 Outbox Job。
     * 需 {@code PushProperties.isMockAllowed}。
     */
    PushMockEnqueueVO mockEnqueue(long currentUserId, PushMockEnqueueInDto body);
}
