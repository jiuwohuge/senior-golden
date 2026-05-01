package cn.nine.pros.post.client.api.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.db.ActionDTO;
import cn.nine.pros.post.client.model.db.LoginDTO;
import cn.nine.pros.post.client.model.input.admin.ActionLogQueryInDto;
import cn.nine.pros.post.client.model.input.admin.LoginLogQueryInDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@Tag(name = "管理后台-日志查看API")
public interface AdminLogApi {

    @Operation(summary = "登录日志列表")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/log/login/list")
    PageData<LoginDTO> listLoginLogs(@RequestBody @Validated LoginLogQueryInDto query);

    @Operation(summary = "行为日志列表")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/log/action/list")
    PageData<ActionDTO> listActionLogs(@RequestBody @Validated ActionLogQueryInDto query);
}