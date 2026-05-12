package cn.nine.pros.post.client.api.app;

import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.input.app.AppFeedbackSubmitInDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

@Tag(name = "App-反馈建议")
@RequestMapping(AppServiceDefine.SERVER_PREFIX + "/feedback")
public interface AppFeedbackApi {

    @Operation(summary = "提交使用反馈或建议")
    @PostMapping
    void submit(@RequestBody @Valid AppFeedbackSubmitInDto body);
}
