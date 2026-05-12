package cn.nine.pros.post.client.api.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.input.admin.AppFeedbackAdminQueryInDto;
import cn.nine.pros.post.client.model.out.AppFeedbackAdminItemVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

@Tag(name = "管理后台-APP 反馈")
@RequestMapping(AppServiceDefine.WEBAPI_PREFIX + "/feedback")
public interface AdminAppFeedbackApi {

    @Operation(summary = "分页查询 APP 反馈")
    @PostMapping("/paging")
    PageData<AppFeedbackAdminItemVO> paging(@RequestBody @Valid AppFeedbackAdminQueryInDto body);
}
