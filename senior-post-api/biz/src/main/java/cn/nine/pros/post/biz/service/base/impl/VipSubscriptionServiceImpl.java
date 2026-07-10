package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.nine.pros.post.biz.mapper.VipSubscriptionMapper;
import cn.nine.pros.post.biz.model.domain.VipSubscriptionDomain;
import cn.nine.pros.post.biz.model.mapstruct.VipSubscriptionMapstruct;
import cn.nine.pros.post.biz.service.base.VipSubscriptionService;
import cn.nine.pros.post.client.model.db.VipSubscriptionDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * VIP订阅记录表 ServiceImpl
 *
 * @author Administrator
 */
@Service
public class VipSubscriptionServiceImpl extends ServiceImpl<VipSubscriptionMapper, VipSubscriptionDomain>
        implements VipSubscriptionService {

    @Autowired
    private VipSubscriptionMapstruct vipSubscriptionMapstruct;

    @Override
    public void upsert(VipSubscriptionDTO vipSubscriptionDTO) {
        Long id = vipSubscriptionDTO.getId();
        if (id == null) {
            VipSubscriptionDomain domain = vipSubscriptionMapstruct.toDomain(vipSubscriptionDTO);
            domain.initAudit(MyRequestContextHolder.userId());
            save(domain);
            return;
        }
        VipSubscriptionDomain domain = vipSubscriptionMapstruct.toDomain(vipSubscriptionDTO);
        domain.setId(id);
        domain.setUpdatedAt(LocalDateTime.now());
        domain.setUpdatedBy(MyRequestContextHolder.userId());
        updateById(domain);
    }

    @Override
    public VipSubscriptionDTO findById(Long id) {
        return vipSubscriptionMapstruct.toDTO(getById(id));
    }

    @Override
    public void delByIds(List<Long> ids) {
        VipSubscriptionDomain vipSubscriptionDomain = new VipSubscriptionDomain();
        vipSubscriptionDomain.setDelFlag(true);
        vipSubscriptionDomain.setUpdatedAt(LocalDateTime.now());
        update(vipSubscriptionDomain, new LambdaQueryWrapper<VipSubscriptionDomain>()
                .in(VipSubscriptionDomain::getId, ids));
    }

    @Override
    public long countActive() {
        return count(new LambdaQueryWrapper<VipSubscriptionDomain>()
                .eq(VipSubscriptionDomain::isDelFlag, false));
    }

}