package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.model.domain.ConfigDomain;
import cn.nine.pros.post.biz.model.mapstruct.ConfigMapstruct;
import cn.nine.pros.post.biz.service.base.ConfigService;
import cn.nine.pros.post.client.api.admin.AdminConfigApi;
import cn.nine.pros.post.client.model.db.ConfigDTO;
import cn.nine.pros.post.client.model.input.admin.ConfigInDto;
import cn.nine.pros.post.client.model.input.admin.ConfigQueryInDto;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.apache.commons.lang3.StringUtils;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequiredArgsConstructor
public class AdminConfigController implements AdminConfigApi {

    private final ConfigService configService;
    private final ConfigMapstruct configMapstruct;

    @Override
    public PageData<ConfigDTO> paging(ConfigQueryInDto body) {
        PageQuery pageQuery = AdminPageHelper.normalize(body.getPage());
        LambdaQueryWrapper<ConfigDomain> qw = new LambdaQueryWrapper<ConfigDomain>()
                .eq(ConfigDomain::isDelFlag, false)
                .orderByAsc(ConfigDomain::getConfigGroup)
                .orderByAsc(ConfigDomain::getConfigKey);
        if (StringUtils.isNotBlank(body.getConfigGroup())) {
            qw.eq(ConfigDomain::getConfigGroup, body.getConfigGroup().trim());
        }
        Page<ConfigDomain> p = configService.page(AdminPageHelper.mpPage(pageQuery), qw);
        List<ConfigDTO> list = p.getRecords().stream().map(configMapstruct::toDTO).collect(Collectors.toList());
        return AdminPageHelper.pageData(pageQuery, p, list);
    }

    @Override
    public void save(ConfigInDto body) {
        ConfigDTO dto = new ConfigDTO();
        dto.setId(body.getId());
        dto.setConfigKey(body.getConfigKey());
        dto.setConfigValue(body.getConfigValue());
        dto.setConfigGroup(body.getConfigGroup());
        dto.setDescription(body.getDescription());
        configService.upsert(dto);
    }

    @Override
    public void delete(Integer id) {
        configService.delByIds(java.util.List.of(id));
    }
}
