package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.nine.pros.post.biz.mapper.StampTransactionMapper;
import cn.nine.pros.post.biz.model.domain.StampTransactionDomain;
import cn.nine.pros.post.biz.model.mapstruct.StampTransactionMapstruct;
import cn.nine.pros.post.biz.service.base.StampTransactionService;
import cn.nine.pros.post.client.model.db.StampTransactionDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 邮票变更流水日志 ServiceImpl
 *
 * @author Administrator
 */
@Service
public class StampTransactionServiceImpl extends ServiceImpl<StampTransactionMapper, StampTransactionDomain>
        implements StampTransactionService {

    @Autowired
    private StampTransactionMapstruct stampTransactionMapstruct;

    @Override
    public void upsert(StampTransactionDTO stampTransactionDTO) {
        Long id = stampTransactionDTO.getId();
        if (id == null) {
            StampTransactionDomain domain = stampTransactionMapstruct.toDomain(stampTransactionDTO);
            domain.initAudit(MyRequestContextHolder.userId());
            save(domain);
            return;
        }
        StampTransactionDomain domain = stampTransactionMapstruct.toDomain(stampTransactionDTO);
        domain.setId(id);
        domain.setUpdatedAt(LocalDateTime.now());
        domain.setUpdatedBy(MyRequestContextHolder.userId());
        updateById(domain);
    }

    @Override
    public StampTransactionDTO findById(Long id) {
        return stampTransactionMapstruct.toDTO(getById(id));
    }

    @Override
    public void delByIds(List<Long> ids) {
        StampTransactionDomain stampTransactionDomain = new StampTransactionDomain();
        stampTransactionDomain.setDelFlag(true);
        stampTransactionDomain.setUpdatedAt(LocalDateTime.now());
        update(stampTransactionDomain, new LambdaQueryWrapper<StampTransactionDomain>()
                .in(StampTransactionDomain::getId, ids));
    }

}