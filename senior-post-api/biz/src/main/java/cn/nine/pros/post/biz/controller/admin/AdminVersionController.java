package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.model.domain.AppVersionDomain;
import cn.nine.pros.post.biz.model.mapstruct.AppVersionMapstruct;
import cn.nine.pros.post.biz.service.base.AppVersionService;
import cn.nine.pros.post.client.api.admin.AdminVersionApi;
import cn.nine.pros.post.client.model.db.AppVersionDTO;
import cn.nine.pros.post.client.model.input.admin.AppVersionInDto;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequiredArgsConstructor
public class AdminVersionController implements AdminVersionApi {

    private final AppVersionService appVersionService;
    private final AppVersionMapstruct appVersionMapstruct;

    @Override
    public PageData<AppVersionDTO> paging(AppVersionInDto body) {
        PageQuery pageQuery = AdminPageHelper.normalize(null);
        LambdaQueryWrapper<AppVersionDomain> qw = new LambdaQueryWrapper<AppVersionDomain>()
                .eq(AppVersionDomain::isDelFlag, false)
                .orderByDesc(AppVersionDomain::getCreatedAt);
        Page<AppVersionDomain> p = appVersionService.page(AdminPageHelper.mpPage(pageQuery), qw);
        List<AppVersionDTO> list = p.getRecords().stream().map(appVersionMapstruct::toDTO).collect(Collectors.toList());
        return AdminPageHelper.pageData(pageQuery, p, list);
    }

    @Override
    public void save(AppVersionInDto body) {
        AppVersionDTO dto = new AppVersionDTO();
        dto.setId(body.getId());
        dto.setVersionCode(body.getVersion());
        dto.setAppPlatform(body.getPlatform() != null && body.getPlatform() == 1 ? "ios" : "android");
        dto.setUpdateUrl(body.getDownloadUrl());
        dto.setReleaseNote(body.getUpdateContent());
        dto.setForceUpdate(body.getIsForceUpdate());
        dto.setMinSupportedVersion(body.getMinVersion());
        appVersionService.upsert(dto);
    }

    @Override
    public void delete(Integer id) {
        appVersionService.delByIds(java.util.List.of(id));
    }
}
