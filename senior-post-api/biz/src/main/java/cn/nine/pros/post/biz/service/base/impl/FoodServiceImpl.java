package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.nine.pros.post.biz.mapper.FoodMapper;
import cn.nine.pros.post.biz.model.domain.FoodDomain;
import cn.nine.pros.post.biz.model.mapstruct.FoodMapstruct;
import cn.nine.pros.post.biz.service.base.FoodService;
import cn.nine.pros.post.client.model.db.FoodDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * ${classComments} ServiceImpl
 *
 * @author Administrator
 */
@Service
public class FoodServiceImpl extends ServiceImpl<FoodMapper, FoodDomain>
        implements FoodService {

    @Autowired
    private FoodMapstruct foodMapstruct;

    @Override
    public void upsert(FoodDTO foodDTO) {
        Long id = foodDTO.getId();
        if (id == null) {
            FoodDomain domain = foodMapstruct.toDomain(foodDTO);
            domain.initAudit(MyRequestContextHolder.userId());
            save(domain);
            return;
        }
        FoodDomain domain = foodMapstruct.toDomain(foodDTO);
        domain.setId(id);
        domain.setUpdatedAt(LocalDateTime.now());
        domain.setUpdatedBy(MyRequestContextHolder.userId());
        updateById(domain);
    }

    @Override
    public FoodDTO findById(Long id) {
        return foodMapstruct.toDTO(getById(id));
    }

    @Override
    public void delByIds(List<Long> ids) {
        FoodDomain foodDomain = new FoodDomain();
        foodDomain.setDelFlag(true);
        foodDomain.setUpdatedAt(LocalDateTime.now());
        update(foodDomain, new LambdaQueryWrapper<FoodDomain>()
                .in(FoodDomain::getId, ids));
    }

}