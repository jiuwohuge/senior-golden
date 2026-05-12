package cn.nine.pros.post.client.api.app;

import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.input.app.AppReportCreateInDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

@Tag(name = "App-举报")
@RequestMapping(AppServiceDefine.SERVER_PREFIX + "/reports")
public interface AppReportApi {

    @Operation(summary = "提交举报（明信片或评论）")
    @PostMapping
    void submit(@RequestBody @Valid AppReportCreateInDto body);
}
