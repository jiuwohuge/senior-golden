package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.nine.pros.post.biz.mapper.SensitiveWordMapper;
import cn.nine.pros.post.biz.model.domain.SensitiveWordDomain;
import cn.nine.pros.post.biz.model.mapstruct.SensitiveWordMapstruct;
import cn.nine.pros.post.biz.service.base.SensitiveWordService;
import cn.nine.pros.post.client.model.db.SensitiveWordDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 敏感词库表 ServiceImpl
 *
 * @author Administrator
 */
@Service
public class SensitiveWordServiceImpl extends ServiceImpl<SensitiveWordMapper, SensitiveWordDomain>
        implements SensitiveWordService {

    @Autowired
    private SensitiveWordMapstruct sensitiveWordMapstruct;

    @Override
    public void upsert(SensitiveWordDTO sensitiveWordDTO) {
        Integer id = sensitiveWordDTO.getId();
        if (id == null) {
            SensitiveWordDomain domain = sensitiveWordMapstruct.toDomain(sensitiveWordDTO);
            domain.initAudit(MyRequestContextHolder.userId());
            save(domain);
            return;
        }
        SensitiveWordDomain domain = sensitiveWordMapstruct.toDomain(sensitiveWordDTO);
        domain.setId(id);
        domain.setUpdatedAt(LocalDateTime.now());
        domain.setUpdatedBy(MyRequestContextHolder.userId());
        updateById(domain);
    }

    @Override
    public SensitiveWordDTO findById(Integer id) {
        return sensitiveWordMapstruct.toDTO(getById(id));
    }

    @Override
    public void delByIds(List<Integer> ids) {
        SensitiveWordDomain sensitiveWordDomain = new SensitiveWordDomain();
        sensitiveWordDomain.setDelFlag(true);
        sensitiveWordDomain.setUpdatedAt(LocalDateTime.now());
        update(sensitiveWordDomain, new LambdaQueryWrapper<SensitiveWordDomain>()
                .in(SensitiveWordDomain::getId, ids));
    }

}