package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.nine.pros.post.biz.mapper.AppVersionMapper;
import cn.nine.pros.post.biz.model.domain.AppVersionDomain;
import cn.nine.pros.post.biz.model.mapstruct.AppVersionMapstruct;
import cn.nine.pros.post.biz.service.base.AppVersionService;
import cn.nine.pros.post.client.model.db.AppVersionDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * App版本控制表 ServiceImpl
 *
 * @author Administrator
 */
@Service
public class AppVersionServiceImpl extends ServiceImpl<AppVersionMapper, AppVersionDomain>
        implements AppVersionService {

    @Autowired
    private AppVersionMapstruct appVersionMapstruct;

    @Override
    public void upsert(AppVersionDTO appVersionDTO) {
        Integer id = appVersionDTO.getId();
        if (id == null) {
            AppVersionDomain domain = appVersionMapstruct.toDomain(appVersionDTO);
            domain.initAudit(MyRequestContextHolder.userId());
            save(domain);
            return;
        }
        AppVersionDomain domain = appVersionMapstruct.toDomain(appVersionDTO);
        domain.setId(id);
        domain.setUpdatedAt(LocalDateTime.now());
        domain.setUpdatedBy(MyRequestContextHolder.userId());
        updateById(domain);
    }

    @Override
    public AppVersionDTO findById(Integer id) {
        return appVersionMapstruct.toDTO(getById(id));
    }

    @Override
    public void delByIds(List<Integer> ids) {
        AppVersionDomain appVersionDomain = new AppVersionDomain();
        appVersionDomain.setDelFlag(true);
        appVersionDomain.setUpdatedAt(LocalDateTime.now());
        update(appVersionDomain, new LambdaQueryWrapper<AppVersionDomain>()
                .in(AppVersionDomain::getId, ids));
    }

}