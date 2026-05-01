package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.nine.pros.post.biz.mapper.VisitorRecordMapper;
import cn.nine.pros.post.biz.model.domain.VisitorRecordDomain;
import cn.nine.pros.post.biz.model.mapstruct.VisitorRecordMapstruct;
import cn.nine.pros.post.biz.service.base.VisitorRecordService;
import cn.nine.pros.post.client.model.db.VisitorRecordDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 访客记录表 ServiceImpl
 *
 * @author Administrator
 */
@Service
public class VisitorRecordServiceImpl extends ServiceImpl<VisitorRecordMapper, VisitorRecordDomain>
        implements VisitorRecordService {

    @Autowired
    private VisitorRecordMapstruct visitorRecordMapstruct;

    @Override
    public void upsert(VisitorRecordDTO visitorRecordDTO) {
        Long id = visitorRecordDTO.getId();
        if (id == null) {
            VisitorRecordDomain domain = visitorRecordMapstruct.toDomain(visitorRecordDTO);
            domain.initAudit(MyRequestContextHolder.userId());
            save(domain);
            return;
        }
        VisitorRecordDomain domain = visitorRecordMapstruct.toDomain(visitorRecordDTO);
        domain.setId(id);
        domain.setUpdatedAt(LocalDateTime.now());
        domain.setUpdatedBy(MyRequestContextHolder.userId());
        updateById(domain);
    }

    @Override
    public VisitorRecordDTO findById(Long id) {
        return visitorRecordMapstruct.toDTO(getById(id));
    }

    @Override
    public void delByIds(List<Long> ids) {
        VisitorRecordDomain visitorRecordDomain = new VisitorRecordDomain();
        visitorRecordDomain.setDelFlag(true);
        visitorRecordDomain.setUpdatedAt(LocalDateTime.now());
        update(visitorRecordDomain, new LambdaQueryWrapper<VisitorRecordDomain>()
                .in(VisitorRecordDomain::getId, ids));
    }

}