package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.nine.pros.post.biz.mapper.ImMessageMapper;
import cn.nine.pros.post.biz.model.domain.ImMessageDomain;
import cn.nine.pros.post.biz.model.mapstruct.ImMessageMapstruct;
import cn.nine.pros.post.biz.service.base.ImMessageService;
import cn.nine.pros.post.client.model.db.ImMessageDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * IM消息表 ServiceImpl
 *
 * @author Administrator
 */
@Service
public class ImMessageServiceImpl extends ServiceImpl<ImMessageMapper, ImMessageDomain>
        implements ImMessageService {

    @Autowired
    private ImMessageMapstruct imMessageMapstruct;

    @Override
    public void upsert(ImMessageDTO imMessageDTO) {
        Long id = imMessageDTO.getId();
        if (id == null) {
            ImMessageDomain domain = imMessageMapstruct.toDomain(imMessageDTO);
            domain.initAudit(MyRequestContextHolder.userId());
            save(domain);
            return;
        }
        ImMessageDomain domain = imMessageMapstruct.toDomain(imMessageDTO);
        domain.setId(id);
        domain.setUpdatedAt(LocalDateTime.now());
        domain.setUpdatedBy(MyRequestContextHolder.userId());
        updateById(domain);
    }

    @Override
    public ImMessageDTO findById(Long id) {
        return imMessageMapstruct.toDTO(getById(id));
    }

    @Override
    public void delByIds(List<Long> ids) {
        ImMessageDomain imMessageDomain = new ImMessageDomain();
        imMessageDomain.setDelFlag(true);
        imMessageDomain.setUpdatedAt(LocalDateTime.now());
        update(imMessageDomain, new LambdaQueryWrapper<ImMessageDomain>()
                .in(ImMessageDomain::getId, ids));
    }

}