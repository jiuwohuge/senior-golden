package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
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

}