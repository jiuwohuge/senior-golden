package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.pros.post.biz.support.PageQueryNormalize;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.nine.pros.post.biz.mapper.ConfigMapper;
import cn.nine.pros.post.biz.model.domain.ConfigDomain;
import cn.nine.pros.post.biz.model.mapstruct.ConfigMapstruct;
import cn.nine.pros.post.biz.service.base.ConfigService;
import cn.nine.pros.post.client.model.db.ConfigDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;

/**
 * 系统配置表 ServiceImpl
 *
 * @author Administrator
 */
@Service
public class ConfigServiceImpl extends ServiceImpl<ConfigMapper, ConfigDomain>
        implements ConfigService {

    @Autowired
    private ConfigMapstruct configMapstruct;

    @Override
    public void upsert(ConfigDTO configDTO) {
        Integer id = configDTO.getId();
        if (id == null) {
            ConfigDomain domain = configMapstruct.toDomain(configDTO);
            domain.initAudit(MyRequestContextHolder.userId());
            save(domain);
            return;
        }
        ConfigDomain domain = configMapstruct.toDomain(configDTO);
        domain.setId(id);
        domain.setUpdatedAt(LocalDateTime.now());
        domain.setUpdatedBy(MyRequestContextHolder.userId());
        updateById(domain);
    }

    @Override
    public ConfigDTO findById(Integer id) {
        return configMapstruct.toDTO(getById(id));
    }

    @Override
    public void delByIds(List<Integer> ids) {
        ConfigDomain configDomain = new ConfigDomain();
        configDomain.setDelFlag(true);
        configDomain.setUpdatedAt(LocalDateTime.now());
        update(configDomain, new LambdaQueryWrapper<ConfigDomain>()
                .in(ConfigDomain::getId, ids));
    }

    @Override
    public ConfigDomain findActiveByKey(String configKey) {
        if (configKey == null || configKey.isBlank()) {
            return null;
        }
        return getOne(new LambdaQueryWrapper<ConfigDomain>()
                .eq(ConfigDomain::isDelFlag, false)
                .eq(ConfigDomain::getConfigKey, configKey)
                .last("limit 1"));
    }

    @Override
    public List<ConfigDomain> listActiveByKeys(Collection<String> configKeys) {
        if (configKeys == null || configKeys.isEmpty()) {
            return List.of();
        }
        return list(new LambdaQueryWrapper<ConfigDomain>()
                .eq(ConfigDomain::isDelFlag, false)
                .in(ConfigDomain::getConfigKey, configKeys));
    }

    @Override
    public int getInt(String configKey, int defaultValue) {
        ConfigDomain cfg = findActiveByKey(configKey);
        if (cfg == null || cfg.getConfigValue() == null || cfg.getConfigValue().isBlank()) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(cfg.getConfigValue().trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    @Override
    public double getDouble(String configKey, double defaultValue) {
        ConfigDomain cfg = findActiveByKey(configKey);
        if (cfg == null || cfg.getConfigValue() == null || cfg.getConfigValue().isBlank()) {
            return defaultValue;
        }
        try {
            return Double.parseDouble(cfg.getConfigValue().trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    @Override
    public boolean getBoolean(String configKey, boolean defaultValue) {
        ConfigDomain cfg = findActiveByKey(configKey);
        if (cfg == null || cfg.getConfigValue() == null || cfg.getConfigValue().isBlank()) {
            return defaultValue;
        }
        String v = cfg.getConfigValue().trim().toLowerCase();
        if ("true".equals(v) || "1".equals(v) || "yes".equals(v) || "on".equals(v)) {
            return true;
        }
        if ("false".equals(v) || "0".equals(v) || "no".equals(v) || "off".equals(v)) {
            return false;
        }
        return defaultValue;
    }


    @Override
    public com.baomidou.mybatisplus.extension.plugins.pagination.Page<ConfigDomain> pageForAdmin(
            cn.nine.commons.data.page.PageQuery pageQuery, String configGroup) {
        LambdaQueryWrapper<ConfigDomain> qw = new LambdaQueryWrapper<ConfigDomain>()
                .eq(ConfigDomain::isDelFlag, false)
                .orderByAsc(ConfigDomain::getConfigGroup)
                .orderByAsc(ConfigDomain::getConfigKey);
        if (configGroup != null && !configGroup.isBlank()) {
            qw.eq(ConfigDomain::getConfigGroup, configGroup.trim());
        }
        return page(PageQueryNormalize.mpPage(pageQuery, PageQueryNormalize.ADMIN_MAX_SIZE), qw);
    }

}