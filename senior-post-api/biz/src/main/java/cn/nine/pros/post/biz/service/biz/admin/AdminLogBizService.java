package cn.nine.pros.post.biz.service.biz.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.controller.admin.AdminPageHelper;
import cn.nine.pros.post.biz.model.domain.ActionDomain;
import cn.nine.pros.post.biz.model.domain.LoginDomain;
import cn.nine.pros.post.biz.model.mapstruct.ActionMapstruct;
import cn.nine.pros.post.biz.model.mapstruct.LoginMapstruct;
import cn.nine.pros.post.biz.service.base.ActionService;
import cn.nine.pros.post.biz.service.base.LoginService;
import cn.nine.pros.post.client.model.db.ActionDTO;
import cn.nine.pros.post.client.model.db.LoginDTO;
import cn.nine.pros.post.client.model.input.admin.ActionLogQueryInDto;
import cn.nine.pros.post.client.model.input.admin.LoginLogQueryInDto;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 管理端行为日志与登录日志查询。
 */
@Service
@RequiredArgsConstructor
public class AdminLogBizService {

    private final ActionService actionService;
    private final ActionMapstruct actionMapstruct;
    private final LoginService loginService;
    private final LoginMapstruct loginMapstruct;

    /**
     * 按用户/动作类型分页查询行为日志。
     */
    public PageData<ActionDTO> pagingActions(ActionLogQueryInDto body) {
        PageQuery pageQuery = AdminPageHelper.normalize(body.getPage());
        Page<ActionDomain> p = actionService.pageForAdmin(pageQuery, body.getUserId(), body.getActionType());
        List<ActionDTO> list = p.getRecords().stream().map(actionMapstruct::toDTO).collect(Collectors.toList());
        return AdminPageHelper.pageData(pageQuery, p, list);
    }

    /**
     * 按用户/登录结果分页查询登录日志。
     */
    public PageData<LoginDTO> pagingLogins(LoginLogQueryInDto body) {
        PageQuery pageQuery = AdminPageHelper.normalize(body.getPage());
        Page<LoginDomain> p = loginService.pageForAdmin(pageQuery, body.getUserId(), body.getLoginResult());
        List<LoginDTO> list = p.getRecords().stream().map(loginMapstruct::toDTO).collect(Collectors.toList());
        return AdminPageHelper.pageData(pageQuery, p, list);
    }
}
