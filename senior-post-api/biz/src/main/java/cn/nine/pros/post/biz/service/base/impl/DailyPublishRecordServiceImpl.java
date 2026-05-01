package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.nine.pros.post.biz.mapper.DailyPublishRecordMapper;
import cn.nine.pros.post.biz.model.domain.DailyPublishRecordDomain;
import cn.nine.pros.post.biz.model.mapstruct.DailyPublishRecordMapstruct;
import cn.nine.pros.post.biz.service.base.DailyPublishRecordService;
import cn.nine.pros.post.client.model.db.DailyPublishRecordDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 每日发布记录表 ServiceImpl
 *
 * @author Administrator
 */
@Service
public class DailyPublishRecordServiceImpl extends ServiceImpl<DailyPublishRecordMapper, DailyPublishRecordDomain>
        implements DailyPublishRecordService {

    @Autowired
    private DailyPublishRecordMapstruct dailyPublishRecordMapstruct;

    @Override
    public void upsert(DailyPublishRecordDTO dailyPublishRecordDTO) {
        Long id = dailyPublishRecordDTO.getId();
        if (id == null) {
            DailyPublishRecordDomain domain = dailyPublishRecordMapstruct.toDomain(dailyPublishRecordDTO);
            domain.initAudit(MyRequestContextHolder.userId());
            save(domain);
            return;
        }
        DailyPublishRecordDomain domain = dailyPublishRecordMapstruct.toDomain(dailyPublishRecordDTO);
        domain.setId(id);
        domain.setUpdatedAt(LocalDateTime.now());
        domain.setUpdatedBy(MyRequestContextHolder.userId());
        updateById(domain);
    }

    @Override
    public DailyPublishRecordDTO findById(Long id) {
        return dailyPublishRecordMapstruct.toDTO(getById(id));
    }

    @Override
    public void delByIds(List<Long> ids) {
        DailyPublishRecordDomain dailyPublishRecordDomain = new DailyPublishRecordDomain();
        dailyPublishRecordDomain.setDelFlag(true);
        dailyPublishRecordDomain.setUpdatedAt(LocalDateTime.now());
        update(dailyPublishRecordDomain, new LambdaQueryWrapper<DailyPublishRecordDomain>()
                .in(DailyPublishRecordDomain::getId, ids));
    }

}