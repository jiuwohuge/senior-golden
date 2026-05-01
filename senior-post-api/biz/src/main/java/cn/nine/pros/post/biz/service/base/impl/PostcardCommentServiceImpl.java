package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.nine.pros.post.biz.mapper.PostcardCommentMapper;
import cn.nine.pros.post.biz.model.domain.PostcardCommentDomain;
import cn.nine.pros.post.biz.model.mapstruct.PostcardCommentMapstruct;
import cn.nine.pros.post.biz.service.base.PostcardCommentService;
import cn.nine.pros.post.client.model.db.PostcardCommentDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 明信片评论表 ServiceImpl
 *
 * @author Administrator
 */
@Service
public class PostcardCommentServiceImpl extends ServiceImpl<PostcardCommentMapper, PostcardCommentDomain>
        implements PostcardCommentService {

    @Autowired
    private PostcardCommentMapstruct postcardCommentMapstruct;

    @Override
    public void upsert(PostcardCommentDTO postcardCommentDTO) {
        Long id = postcardCommentDTO.getId();
        if (id == null) {
            PostcardCommentDomain domain = postcardCommentMapstruct.toDomain(postcardCommentDTO);
            domain.initAudit(MyRequestContextHolder.userId());
            save(domain);
            return;
        }
        PostcardCommentDomain domain = postcardCommentMapstruct.toDomain(postcardCommentDTO);
        domain.setId(id);
        domain.setUpdatedAt(LocalDateTime.now());
        domain.setUpdatedBy(MyRequestContextHolder.userId());
        updateById(domain);
    }

    @Override
    public PostcardCommentDTO findById(Long id) {
        return postcardCommentMapstruct.toDTO(getById(id));
    }

    @Override
    public void delByIds(List<Long> ids) {
        PostcardCommentDomain postcardCommentDomain = new PostcardCommentDomain();
        postcardCommentDomain.setDelFlag(true);
        postcardCommentDomain.setUpdatedAt(LocalDateTime.now());
        update(postcardCommentDomain, new LambdaQueryWrapper<PostcardCommentDomain>()
                .in(PostcardCommentDomain::getId, ids));
    }

}