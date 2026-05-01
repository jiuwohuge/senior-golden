package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.pros.post.biz.model.domain.AppVersionDomain;
import cn.nine.pros.post.biz.model.mapstruct.AppVersionMapstruct;
import cn.nine.pros.post.biz.service.base.AppVersionService;
import cn.nine.pros.post.client.api.admin.AdminVersionApi;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.db.AppVersionDTO;
import cn.nine.pros.post.client.model.input.admin.AppVersionInDto;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequiredArgsConstructor
@Tag(name = "管理后台-版本管理API")
public class AdminVersionController implements AdminVersionApi {

    private final AppVersionService appVersionService;
    private final AppVersionMapstruct appVersionMapstruct;

    @Override
    @Operation(summary = "版本列表")
    @GetMapping(AppServiceDefine.WEBAPI_PREFIX + "/version/list")
    public List<AppVersionDTO> listVersions() {
        LambdaQueryWrapper<AppVersionDomain> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(AppVersionDomain::getDelFlag, false);
        wrapper.orderByDesc(AppVersionDomain::getCreatedAt);
        return appVersionService.list(wrapper).stream().map(appVersionMapstruct::toDTO).toList();
    }

    @Override
    @Operation(summary = "创建版本")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/version")
    @Transactional
    public void createVersion(@RequestBody AppVersionInDto version) {
        AppVersionDomain domain = new AppVersionDomain();
        domain.setVersionCode(version.getVersion());
        domain.setAppPlatform(version.getPlatform());
        domain.setUpdateUrl(version.getDownloadUrl());
        domain.setReleaseNote(version.getUpdateContent());
        domain.setForceUpdate(version.getIsForceUpdate());
        domain.setMinSupportedVersion(version.getMinVersion());
        domain.initAudit(MyRequestContextHolder.userId());
        appVersionService.save(domain);
    }

    @Override
    @Operation(summary = "更新版本")
    @PutMapping(AppServiceDefine.WEBAPI_PREFIX + "/version/{id}")
    @Transactional
    public void updateVersion(@PathVariable("id") Integer id, @RequestBody AppVersionInDto version) {
        AppVersionDomain domain = appVersionService.getById(id);
        if (domain == null) {
            throw new cn.nine.commons.basic.exception.BadRequestException("版本不存在");
        }
        domain.setVersionCode(version.getVersion());
        domain.setAppPlatform(version.getPlatform());
        domain.setUpdateUrl(version.getDownloadUrl());
        domain.setReleaseNote(version.getUpdateContent());
        domain.setForceUpdate(version.getIsForceUpdate());
        domain.setMinSupportedVersion(version.getMinVersion());
        domain.updateAudit(MyRequestContextHolder.userId());
        appVersionService.updateById(domain);
    }

    @Override
    @Operation(summary = "删除版本")
    @DeleteMapping(AppServiceDefine.WEBAPI_PREFIX + "/version/{id}")
    @Transactional
    public void deleteVersion(@PathVariable("id") Integer id) {
        AppVersionDomain domain = appVersionService.getById(id);
        if (domain == null) {
            throw new cn.nine.commons.basic.exception.BadRequestException("版本不存在");
        }
        domain.setDelFlag(true);
        appVersionService.updateById(domain);
    }
}