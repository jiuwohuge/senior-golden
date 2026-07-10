package cn.nine.pros.post.biz.service.biz.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.controller.admin.AdminPageHelper;
import cn.nine.pros.post.biz.model.domain.ConfigDomain;
import cn.nine.pros.post.biz.model.mapstruct.ConfigMapstruct;
import cn.nine.pros.post.biz.service.base.ConfigService;
import cn.nine.pros.post.client.model.db.ConfigDTO;
import cn.nine.pros.post.client.model.input.admin.ConfigInDto;
import cn.nine.pros.post.client.model.input.admin.ConfigQueryInDto;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 管理端系统配置 CRUD。
 */
@Service
@RequiredArgsConstructor
public class AdminConfigBizService {

    private final ConfigService configService;
    private final ConfigMapstruct configMapstruct;

    /**
     * 按配置组分页查询系统配置。
     */
    public PageData<ConfigDTO> paging(ConfigQueryInDto body) {
        PageQuery pageQuery = AdminPageHelper.normalize(body.getPage());
        String group = body.getConfigGroup();
        Page<ConfigDomain> p = configService.pageForAdmin(pageQuery, group);
        List<ConfigDTO> list = p.getRecords().stream().map(configMapstruct::toDTO).collect(Collectors.toList());
        return AdminPageHelper.pageData(pageQuery, p, list);
    }

    /**
     * 新增或更新一条系统配置。
     */
    public void save(ConfigInDto body) {
        ConfigDTO dto = new ConfigDTO();
        dto.setId(body.getId());
        dto.setConfigKey(body.getConfigKey());
        dto.setConfigValue(body.getConfigValue());
        dto.setConfigGroup(body.getConfigGroup());
        dto.setDescription(body.getDescription());
        configService.upsert(dto);
    }

    /**
     * 按主键删除系统配置。
     */
    public void delete(Integer id) {
        configService.delByIds(List.of(id));
    }
}
