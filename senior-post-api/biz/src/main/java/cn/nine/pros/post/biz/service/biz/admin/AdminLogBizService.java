package cn.nine.pros.post.biz.service.biz.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.controller.admin.AdminPageHelper;
import cn.nine.pros.post.biz.model.domain.ActionDomain;
import cn.nine.pros.post.biz.model.domain.AdminOperationDomain;
import cn.nine.pros.post.biz.model.domain.LoginDomain;
import cn.nine.pros.post.biz.model.mapstruct.ActionMapstruct;
import cn.nine.pros.post.biz.model.mapstruct.AdminOperationMapstruct;
import cn.nine.pros.post.biz.model.mapstruct.LoginMapstruct;
import cn.nine.pros.post.biz.service.base.ActionService;
import cn.nine.pros.post.biz.service.base.AdminOperationService;
import cn.nine.pros.post.biz.service.base.LoginService;
import cn.nine.pros.post.client.model.db.ActionDTO;
import cn.nine.pros.post.client.model.db.AdminOperationDTO;
import cn.nine.pros.post.client.model.db.LoginDTO;
import cn.nine.pros.post.client.model.input.admin.ActionLogQueryInDto;
import cn.nine.pros.post.client.model.input.admin.AdminOperationQueryInDto;
import cn.nine.pros.post.client.model.input.admin.LoginLogQueryInDto;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 管理端行为日志、登录日志与管理员操作日志查询。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AdminLogBizService {

    private final ActionService actionService;
    private final ActionMapstruct actionMapstruct;
    private final LoginService loginService;
    private final LoginMapstruct loginMapstruct;
    private final AdminOperationService adminOperationService;
    private final AdminOperationMapstruct adminOperationMapstruct;

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

    /**
     * 按管理员/操作类型/目标类型分页查询管理员操作日志。
     */
    public PageData<AdminOperationDTO> pagingAdminOperations(AdminOperationQueryInDto body) {
        PageQuery pageQuery = AdminPageHelper.normalize(body.getPage());
        Page<AdminOperationDomain> p = adminOperationService.pageForAdmin(
                pageQuery, body.getAdminId(), body.getActionType(), body.getTargetType());
        List<AdminOperationDTO> list = p.getRecords().stream()
                .map(adminOperationMapstruct::toDTO)
                .collect(Collectors.toList());
        log.info("admin operation log paging, total={}", p.getTotal());
        return AdminPageHelper.pageData(pageQuery, p, list);
    }
}
