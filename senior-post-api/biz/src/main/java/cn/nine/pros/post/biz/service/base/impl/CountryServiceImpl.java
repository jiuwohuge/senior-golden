package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.nine.pros.post.biz.mapper.CountryMapper;
import cn.nine.pros.post.biz.model.domain.CountryDomain;
import cn.nine.pros.post.biz.model.mapstruct.CountryMapstruct;
import cn.nine.pros.post.biz.service.base.CountryService;
import cn.nine.pros.post.client.model.db.CountryDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 国家地区表 ServiceImpl
 *
 * @author Administrator
 */
@Service
public class CountryServiceImpl extends ServiceImpl<CountryMapper, CountryDomain>
        implements CountryService {

    @Autowired
    private CountryMapstruct countryMapstruct;

    @Override
    public void upsert(CountryDTO countryDTO) {
        Integer id = countryDTO.getId();
        if (id == null) {
            CountryDomain domain = countryMapstruct.toDomain(countryDTO);
            domain.initAudit(MyRequestContextHolder.userId());
            save(domain);
            return;
        }
        CountryDomain domain = countryMapstruct.toDomain(countryDTO);
        domain.setId(id);
        domain.setUpdatedAt(LocalDateTime.now());
        domain.setUpdatedBy(MyRequestContextHolder.userId());
        updateById(domain);
    }

    @Override
    public CountryDTO findById(Integer id) {
        return countryMapstruct.toDTO(getById(id));
    }

    @Override
    public void delByIds(List<Integer> ids) {
        CountryDomain countryDomain = new CountryDomain();
        countryDomain.setDelFlag(true);
        countryDomain.setUpdatedAt(LocalDateTime.now());
        update(countryDomain, new LambdaQueryWrapper<CountryDomain>()
                .in(CountryDomain::getId, ids));
    }

}