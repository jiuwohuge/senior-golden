package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.nine.pros.post.biz.mapper.ImConversationMapper;
import cn.nine.pros.post.biz.model.domain.ImConversationDomain;
import cn.nine.pros.post.biz.model.mapstruct.ImConversationMapstruct;
import cn.nine.pros.post.biz.service.base.ImConversationService;
import cn.nine.pros.post.client.model.db.ImConversationDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * IM会话表（腾讯IM） ServiceImpl
 *
 * @author Administrator
 */
@Service
public class ImConversationServiceImpl extends ServiceImpl<ImConversationMapper, ImConversationDomain>
        implements ImConversationService {

    @Autowired
    private ImConversationMapstruct imConversationMapstruct;

    @Override
    public void upsert(ImConversationDTO imConversationDTO) {
        Long id = imConversationDTO.getId();
        if (id == null) {
            ImConversationDomain domain = imConversationMapstruct.toDomain(imConversationDTO);
            domain.initAudit(MyRequestContextHolder.userId());
            save(domain);
            return;
        }
        ImConversationDomain domain = imConversationMapstruct.toDomain(imConversationDTO);
        domain.setId(id);
        domain.setUpdatedAt(LocalDateTime.now());
        domain.setUpdatedBy(MyRequestContextHolder.userId());
        updateById(domain);
    }

    @Override
    public ImConversationDTO findById(Long id) {
        return imConversationMapstruct.toDTO(getById(id));
    }

    @Override
    public void delByIds(List<Long> ids) {
        ImConversationDomain imConversationDomain = new ImConversationDomain();
        imConversationDomain.setDelFlag(true);
        imConversationDomain.setUpdatedAt(LocalDateTime.now());
        update(imConversationDomain, new LambdaQueryWrapper<ImConversationDomain>()
                .in(ImConversationDomain::getId, ids));
    }

}