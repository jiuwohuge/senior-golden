package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.nine.pros.post.biz.mapper.PostcardMapper;
import cn.nine.pros.post.biz.model.domain.PostcardDomain;
import cn.nine.pros.post.biz.model.mapstruct.PostcardMapstruct;
import cn.nine.pros.post.biz.service.base.PostcardService;
import cn.nine.pros.post.client.model.db.PostcardDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 明信片墙表（用户发布的公开明信片） ServiceImpl
 *
 * @author Administrator
 */
@Service
public class PostcardServiceImpl extends ServiceImpl<PostcardMapper, PostcardDomain>
        implements PostcardService {

    @Autowired
    private PostcardMapstruct postcardMapstruct;

    @Override
    public void upsert(PostcardDTO postcardDTO) {
        Long id = postcardDTO.getId();
        if (id == null) {
            PostcardDomain domain = postcardMapstruct.toDomain(postcardDTO);
            domain.initAudit(MyRequestContextHolder.userId());
            save(domain);
            return;
        }
        PostcardDomain domain = postcardMapstruct.toDomain(postcardDTO);
        domain.setId(id);
        domain.setUpdatedAt(LocalDateTime.now());
        domain.setUpdatedBy(MyRequestContextHolder.userId());
        updateById(domain);
    }

    @Override
    public PostcardDTO findById(Long id) {
        return postcardMapstruct.toDTO(getById(id));
    }

    @Override
    public void delByIds(List<Long> ids) {
        PostcardDomain postcardDomain = new PostcardDomain();
        postcardDomain.setDelFlag(true);
        postcardDomain.setUpdatedAt(LocalDateTime.now());
        update(postcardDomain, new LambdaQueryWrapper<PostcardDomain>()
                .in(PostcardDomain::getId, ids));
    }

}