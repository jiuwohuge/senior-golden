package cn.nine.pros.post.biz.service.app;

import cn.nine.pros.post.client.model.input.app.AppFeedbackSubmitInDto;

public interface AppFeedbackService {

    void submit(long userId, AppFeedbackSubmitInDto body);
}
