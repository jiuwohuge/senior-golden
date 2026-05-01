package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.model.domain.ActionDomain;
import cn.nine.pros.post.biz.model.domain.LoginDomain;
import cn.nine.pros.post.biz.model.mapstruct.ActionMapstruct;
import cn.nine.pros.post.biz.model.mapstruct.LoginMapstruct;
import cn.nine.pros.post.biz.service.base.ActionService;
import cn.nine.pros.post.biz.service.base.LoginService;
import cn.nine.pros.post.client.api.admin.AdminLogApi;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.db.ActionDTO;
import cn.nine.pros.post.client.model.db.LoginDTO;
import cn.nine.pros.post.client.model.input.admin.ActionLogQueryInDto;
import cn.nine.pros.post.client.model.input.admin.LoginLogQueryInDto;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequiredArgsConstructor
@Tag(name = "管理后台-日志查看API")
public class AdminLogController implements AdminLogApi {

    private final LoginService loginService;
    private final LoginMapstruct loginMapstruct;
    private final ActionService actionService;
    private final ActionMapstruct actionMapstruct;

    @Override
    @Operation(summary = "登录日志列表")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/log/login/list")
    public PageData<LoginDTO> listLoginLogs(@RequestBody LoginLogQueryInDto query) {
        PageQuery pageQuery = query.getPage() != null ? query.getPage() : new PageQuery();
        int pageNum = pageQuery.getPage() != null ? pageQuery.getPage() : 1;
        int pageSize = pageQuery.getSize() != null ? pageQuery.getSize() : 10;

        LambdaQueryWrapper<LoginDomain> wrapper = new LambdaQueryWrapper<>();
        if (query.getUserId() != null) {
            wrapper.eq(LoginDomain::getUserId, query.getUserId());
        }
        if (query.getLoginResult() != null) {
            wrapper.eq(LoginDomain::getLoginResult, query.getLoginResult());
        }
        wrapper.eq(LoginDomain::getDelFlag, false);
        wrapper.orderByDesc(LoginDomain::getCreatedAt);

        Page<LoginDomain> page = loginService.page(new Page<>(pageNum, pageSize), wrapper);
        List<LoginDTO> records = page.getRecords().stream().map(loginMapstruct::toDTO).toList();

        PageData<LoginDTO> result = new PageData<>();
        result.setRecords(records);
        result.setTotal(page.getTotal());
        result.setPages(page.getPages());
        result.setPage(page.getCurrent());
        result.setSize(page.getSize());
        return result;
    }

    @Override
    @Operation(summary = "行为日志列表")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/log/action/list")
    public PageData<ActionDTO> listActionLogs(@RequestBody ActionLogQueryInDto query) {
        PageQuery pageQuery = query.getPage() != null ? query.getPage() : new PageQuery();
        int pageNum = pageQuery.getPage() != null ? pageQuery.getPage() : 1;
        int pageSize = pageQuery.getSize() != null ? pageQuery.getSize() : 10;

        LambdaQueryWrapper<ActionDomain> wrapper = new LambdaQueryWrapper<>();
        if (query.getUserId() != null) {
            wrapper.eq(ActionDomain::getUserId, query.getUserId());
        }
        if (query.getActionType() != null && !query.getActionType().isEmpty()) {
            wrapper.eq(ActionDomain::getActionType, query.getActionType());
        }
        wrapper.eq(ActionDomain::getDelFlag, false);
        wrapper.orderByDesc(ActionDomain::getCreatedAt);

        Page<ActionDomain> page = actionService.page(new Page<>(pageNum, pageSize), wrapper);
        List<ActionDTO> records = page.getRecords().stream().map(actionMapstruct::toDTO).toList();

        PageData<ActionDTO> result = new PageData<>();
        result.setRecords(records);
        result.setTotal(page.getTotal());
        result.setPages(page.getPages());
        result.setPage(page.getCurrent());
        result.setSize(page.getSize());
        return result;
    }
}