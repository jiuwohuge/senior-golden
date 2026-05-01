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
import cn.nine.pros.post.client.model.db.ActionDTO;
import cn.nine.pros.post.client.model.db.LoginDTO;
import cn.nine.pros.post.client.model.input.admin.ActionLogQueryInDto;
import cn.nine.pros.post.client.model.input.admin.LoginLogQueryInDto;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.apache.commons.lang3.StringUtils;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequiredArgsConstructor
public class AdminLogController implements AdminLogApi {

    private final ActionService actionService;
    private final ActionMapstruct actionMapstruct;
    private final LoginService loginService;
    private final LoginMapstruct loginMapstruct;

    @Override
    public PageData<ActionDTO> pagingActions(ActionLogQueryInDto body) {
        PageQuery pageQuery = AdminPageHelper.normalize(body.getPage());
        LambdaQueryWrapper<ActionDomain> qw = new LambdaQueryWrapper<ActionDomain>()
                .eq(ActionDomain::isDelFlag, false)
                .orderByDesc(ActionDomain::getCreatedAt);
        if (body.getUserId() != null) {
            qw.eq(ActionDomain::getUserId, body.getUserId());
        }
        if (StringUtils.isNotBlank(body.getActionType())) {
            qw.eq(ActionDomain::getActionType, body.getActionType().trim());
        }
        Page<ActionDomain> p = actionService.page(AdminPageHelper.mpPage(pageQuery), qw);
        List<ActionDTO> list = p.getRecords().stream().map(actionMapstruct::toDTO).collect(Collectors.toList());
        return AdminPageHelper.pageData(pageQuery, p, list);
    }

    @Override
    public PageData<LoginDTO> pagingLogins(LoginLogQueryInDto body) {
        PageQuery pageQuery = AdminPageHelper.normalize(body.getPage());
        LambdaQueryWrapper<LoginDomain> qw = new LambdaQueryWrapper<LoginDomain>()
                .eq(LoginDomain::isDelFlag, false)
                .orderByDesc(LoginDomain::getCreatedAt);
        if (body.getUserId() != null) {
            qw.eq(LoginDomain::getUserId, body.getUserId());
        }
        if (body.getLoginResult() != null) {
            qw.eq(LoginDomain::getLoginResult, body.getLoginResult());
        }
        Page<LoginDomain> p = loginService.page(AdminPageHelper.mpPage(pageQuery), qw);
        List<LoginDTO> list = p.getRecords().stream().map(loginMapstruct::toDTO).collect(Collectors.toList());
        return AdminPageHelper.pageData(pageQuery, p, list);
    }
}
