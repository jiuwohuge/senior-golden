package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.pros.post.biz.model.domain.ConfigDomain;
import cn.nine.pros.post.biz.model.mapstruct.ConfigMapstruct;
import cn.nine.pros.post.biz.service.base.ConfigService;
import cn.nine.pros.post.client.api.admin.AdminConfigApi;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.db.ConfigDTO;
import cn.nine.pros.post.client.model.input.admin.ConfigInDto;
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
@Tag(name = "管理后台-配置中心API")
public class AdminConfigController implements AdminConfigApi {

    private final ConfigService configService;
    private final ConfigMapstruct configMapstruct;

    @Override
    @Operation(summary = "配置列表")
    @GetMapping(AppServiceDefine.WEBAPI_PREFIX + "/config/list")
    public List<ConfigDTO> listConfigs(@RequestParam(required = false) String group) {
        LambdaQueryWrapper<ConfigDomain> wrapper = new LambdaQueryWrapper<>();
        if (group != null && !group.isEmpty()) {
            wrapper.eq(ConfigDomain::getConfigGroup, group);
        }
        wrapper.eq(ConfigDomain::isDelFlag, false);
        wrapper.orderByAsc(ConfigDomain::getConfigGroup);
        return configService.list(wrapper).stream().map(configMapstruct::toDTO).toList();
    }

    @Override
    @Operation(summary = "创建配置")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/config")
    @Transactional
    public void createConfig(@RequestBody ConfigInDto config) {
        ConfigDomain domain = new ConfigDomain();
        domain.setConfigKey(config.getConfigKey());
        domain.setConfigValue(config.getConfigValue());
        domain.setConfigGroup(config.getConfigGroup());
        domain.setDescription(config.getDescription());
        domain.initAudit(MyRequestContextHolder.userId());
        configService.save(domain);
    }

    @Override
    @Operation(summary = "更新配置")
    @PutMapping(AppServiceDefine.WEBAPI_PREFIX + "/config/{id}")
    @Transactional
    public void updateConfig(@PathVariable("id") Integer id, @RequestBody ConfigInDto config) {
        ConfigDomain domain = configService.getById(id);
        if (domain == null) {
            throw new cn.nine.commons.basic.exception.BadRequestException("配置不存在");
        }
        domain.setConfigKey(config.getConfigKey());
        domain.setConfigValue(config.getConfigValue());
        domain.setConfigGroup(config.getConfigGroup());
        domain.setDescription(config.getDescription());
        domain.updateAudit(MyRequestContextHolder.userId());
        configService.updateById(domain);
    }

    @Override
    @Operation(summary = "删除配置")
    @DeleteMapping(AppServiceDefine.WEBAPI_PREFIX + "/config/{id}")
    @Transactional
    public void deleteConfig(@PathVariable("id") Integer id) {
        ConfigDomain domain = configService.getById(id);
        if (domain == null) {
            throw new cn.nine.commons.basic.exception.BadRequestException("配置不存在");
        }
        domain.setDelFlag(true);
        configService.updateById(domain);
    }

    @Override
    @Operation(summary = "VIP权益配置列表")
    @GetMapping(AppServiceDefine.WEBAPI_PREFIX + "/vip/config/list")
    public List<ConfigDTO> listVipConfigs() {
        LambdaQueryWrapper<ConfigDomain> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ConfigDomain::getConfigGroup, "vip");
        wrapper.eq(ConfigDomain::isDelFlag, false);
        return configService.list(wrapper).stream().map(configMapstruct::toDTO).toList();
    }

    @Override
    @Operation(summary = "更新VIP权益配置")
    @PutMapping(AppServiceDefine.WEBAPI_PREFIX + "/vip/config")
    @Transactional
    public void updateVipConfig(@RequestBody ConfigInDto config) {
        ConfigDomain domain = configService.getOne(
                new LambdaQueryWrapper<ConfigDomain>()
                        .eq(ConfigDomain::getConfigKey, config.getConfigKey())
                        .eq(ConfigDomain::isDelFlag, false)
        );
        if (domain == null) {
            throw new cn.nine.commons.basic.exception.BadRequestException("配置不存在");
        }
        domain.setConfigValue(config.getConfigValue());
        domain.updateAudit(MyRequestContextHolder.userId());
        configService.updateById(domain);
    }
}