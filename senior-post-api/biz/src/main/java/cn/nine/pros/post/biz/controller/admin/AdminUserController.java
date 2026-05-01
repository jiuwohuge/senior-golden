package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.model.domain.UserBlacklistDomain;
import cn.nine.pros.post.biz.model.domain.UserDomain;
import cn.nine.pros.post.biz.model.mapstruct.UserMapstruct;
import cn.nine.pros.post.biz.service.base.UserBlacklistService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.client.api.admin.AdminUserApi;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.db.UserDTO;
import cn.nine.pros.post.client.model.input.admin.DeviceBlockInDto;
import cn.nine.pros.post.client.model.input.admin.UserQueryInDto;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@RestController
@RequiredArgsConstructor
@Tag(name = "管理后台-用户管理API")
public class AdminUserController implements AdminUserApi {

    private final UserService userService;
    private final UserMapstruct userMapstruct;
    private final UserBlacklistService userBlacklistService;

    @Override
    @Operation(summary = "用户列表")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/user/list")
    public PageData<UserDTO> listUsers(@RequestBody UserQueryInDto query) {
        PageQuery pageQuery = query.getPage() != null ? query.getPage() : new PageQuery();
        int pageNum = pageQuery.getPage() != null ? pageQuery.getPage() : 1;
        int pageSize = pageQuery.getSize() != null ? pageQuery.getSize() : 10;

        LambdaQueryWrapper<UserDomain> wrapper = new LambdaQueryWrapper<>();
        if (query.getEmail() != null && !query.getEmail().isEmpty()) {
            wrapper.like(UserDomain::getEmail, query.getEmail());
        }
        if (query.getNickname() != null && !query.getNickname().isEmpty()) {
            wrapper.like(UserDomain::getNickname, query.getNickname());
        }
        if (query.getStatus() != null) {
            wrapper.eq(UserDomain::getStatus, query.getStatus());
        }
        wrapper.eq(UserDomain::getDelFlag, false);
        wrapper.orderByDesc(UserDomain::getCreatedAt);

        Page<UserDomain> page = userService.page(new Page<>(pageNum, pageSize), wrapper);
        List<UserDTO> records = page.getRecords().stream().map(userMapstruct::toDTO).toList();

        PageData<UserDTO> result = new PageData<>();
        result.setRecords(records);
        result.setTotal(page.getTotal());
        result.setPages(page.getPages());
        result.setPage(page.getCurrent());
        result.setSize(page.getSize());
        return result;
    }

    @Override
    @Operation(summary = "封禁用户")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/user/{id}/ban")
    @Transactional
    public void banUser(@PathVariable("id") Long id) {
        UserDomain user = userService.getById(id);
        if (user == null) {
            throw new cn.nine.commons.basic.exception.BadRequestException("用户不存在");
        }
        user.setStatus((short) 2);
        userService.updateById(user);
    }

    @Override
    @Operation(summary = "解封用户")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/user/{id}/unban")
    @Transactional
    public void unbanUser(@PathVariable("id") Long id) {
        UserDomain user = userService.getById(id);
        if (user == null) {
            throw new cn.nine.commons.basic.exception.BadRequestException("用户不存在");
        }
        user.setStatus((short) 1);
        userService.updateById(user);
    }

    @Override
    @Operation(summary = "拉黑设备")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/device/block")
    @Transactional
    public void blockDevice(@RequestBody DeviceBlockInDto req) {
        UserBlacklistDomain blacklist = new UserBlacklistDomain();
        blacklist.setDeviceUuid(req.getDeviceUuid());
        blacklist.setReason(req.getReason());
        blacklist.setAdminId(MyRequestContextHolder.userId());
        blacklist.setExpiredAt(null);
        blacklist.setDelFlag(false);
        userBlacklistService.save(blacklist);
    }
}
