package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.nine.pros.post.biz.mapper.LetterMapper;
import cn.nine.pros.post.biz.model.domain.LetterDomain;
import cn.nine.pros.post.biz.model.mapstruct.LetterMapstruct;
import cn.nine.pros.post.biz.service.base.LetterService;
import cn.nine.pros.post.client.model.db.LetterDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 信件表（挂号信/平邮） ServiceImpl
 *
 * @author Administrator
 */
@Service
public class LetterServiceImpl extends ServiceImpl<LetterMapper, LetterDomain>
        implements LetterService {

    @Autowired
    private LetterMapstruct letterMapstruct;

    @Override
    public void upsert(LetterDTO letterDTO) {
        Long id = letterDTO.getId();
        if (id == null) {
            LetterDomain domain = letterMapstruct.toDomain(letterDTO);
            domain.initAudit(MyRequestContextHolder.userId());
            save(domain);
            return;
        }
        LetterDomain domain = letterMapstruct.toDomain(letterDTO);
        domain.setId(id);
        domain.setUpdatedAt(LocalDateTime.now());
        domain.setUpdatedBy(MyRequestContextHolder.userId());
        updateById(domain);
    }

    @Override
    public LetterDTO findById(Long id) {
        return letterMapstruct.toDTO(getById(id));
    }

    @Override
    public void delByIds(List<Long> ids) {
        LetterDomain letterDomain = new LetterDomain();
        letterDomain.setDelFlag(true);
        letterDomain.setUpdatedAt(LocalDateTime.now());
        update(letterDomain, new LambdaQueryWrapper<LetterDomain>()
                .in(LetterDomain::getId, ids));
    }

}