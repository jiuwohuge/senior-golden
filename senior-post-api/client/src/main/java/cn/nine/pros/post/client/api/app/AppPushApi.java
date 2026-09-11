package cn.nine.pros.post.client.api.app;

import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.input.app.PushMockEnqueueInDto;
import cn.nine.pros.post.client.model.out.PushMockEnqueueVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * App 推送 QA / Mock API。
 */
@Tag(name = "App-Push")
@RequestMapping(AppServiceDefine.SERVER_PREFIX + "/push")
public interface AppPushApi {

    @Operation(summary = "Mock 入队推送并可选立即派发（仅 push.mock-enabled 且非 prod）")
    @PostMapping("/mock-enqueue")
    PushMockEnqueueVO mockEnqueue(@RequestBody @Valid PushMockEnqueueInDto body);
}
