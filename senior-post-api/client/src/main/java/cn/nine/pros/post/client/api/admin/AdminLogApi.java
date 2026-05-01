package cn.nine.pros.post.client.api.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.db.ActionDTO;
import cn.nine.pros.post.client.model.db.LoginDTO;
import cn.nine.pros.post.client.model.input.admin.ActionLogQueryInDto;
import cn.nine.pros.post.client.model.input.admin.LoginLogQueryInDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@Tag(name = "管理后台-日志")
public interface AdminLogApi {

    @Operation(summary = "行为日志分页")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/log/action/paging")
    PageData<ActionDTO> pagingActions(@RequestBody @Valid ActionLogQueryInDto body);

    @Operation(summary = "登录日志分页")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/log/login/paging")
    PageData<LoginDTO> pagingLogins(@RequestBody @Valid LoginLogQueryInDto body);
}
