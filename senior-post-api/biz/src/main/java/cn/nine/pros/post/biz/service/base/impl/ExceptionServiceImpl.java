package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.nine.pros.post.biz.mapper.ExceptionMapper;
import cn.nine.pros.post.biz.model.domain.ExceptionDomain;
import cn.nine.pros.post.biz.model.mapstruct.ExceptionMapstruct;
import cn.nine.pros.post.biz.service.base.ExceptionService;
import cn.nine.pros.post.client.model.db.ExceptionDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 系统异常日志表 ServiceImpl
 *
 * @author Administrator
 */
@Service
public class ExceptionServiceImpl extends ServiceImpl<ExceptionMapper, ExceptionDomain>
        implements ExceptionService {

    @Autowired
    private ExceptionMapstruct exceptionMapstruct;

    @Override
    public void upsert(ExceptionDTO exceptionDTO) {
        Long id = exceptionDTO.getId();
        if (id == null) {
            ExceptionDomain domain = exceptionMapstruct.toDomain(exceptionDTO);
            domain.initAudit(MyRequestContextHolder.userId());
            save(domain);
            return;
        }
        ExceptionDomain domain = exceptionMapstruct.toDomain(exceptionDTO);
        domain.setId(id);
        domain.setUpdatedAt(LocalDateTime.now());
        domain.setUpdatedBy(MyRequestContextHolder.userId());
        updateById(domain);
    }

    @Override
    public ExceptionDTO findById(Long id) {
        return exceptionMapstruct.toDTO(getById(id));
    }

    @Override
    public void delByIds(List<Long> ids) {
        ExceptionDomain exceptionDomain = new ExceptionDomain();
        exceptionDomain.setDelFlag(true);
        exceptionDomain.setUpdatedAt(LocalDateTime.now());
        update(exceptionDomain, new LambdaQueryWrapper<ExceptionDomain>()
                .in(ExceptionDomain::getId, ids));
    }

}