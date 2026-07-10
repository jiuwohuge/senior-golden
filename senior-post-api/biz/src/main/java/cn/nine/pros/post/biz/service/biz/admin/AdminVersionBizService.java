package cn.nine.pros.post.biz.service.biz.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.controller.admin.AdminPageHelper;
import cn.nine.pros.post.biz.model.domain.AppVersionDomain;
import cn.nine.pros.post.biz.model.mapstruct.AppVersionMapstruct;
import cn.nine.pros.post.biz.service.base.AppVersionService;
import cn.nine.pros.post.client.model.db.AppVersionDTO;
import cn.nine.pros.post.client.model.input.admin.AppVersionInDto;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 管理端 App 版本发布 CRUD。
 */
@Service
@RequiredArgsConstructor
public class AdminVersionBizService {

    private final AppVersionService appVersionService;
    private final AppVersionMapstruct appVersionMapstruct;

    /**
     * 分页查询 App 版本列表。
     */
    public PageData<AppVersionDTO> paging(AppVersionInDto body) {
        PageQuery pageQuery = AdminPageHelper.normalize(null);
        Page<AppVersionDomain> p = appVersionService.pageForAdmin(pageQuery);
        List<AppVersionDTO> list = p.getRecords().stream().map(appVersionMapstruct::toDTO).collect(Collectors.toList());
        return AdminPageHelper.pageData(pageQuery, p, list);
    }

    /**
     * 新增或更新 App 版本（含强更与最低支持版本）。
     */
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

    /**
     * 按主键删除 App 版本记录。
     */
    public void delete(Integer id) {
        appVersionService.delByIds(List.of(id));
    }
}
