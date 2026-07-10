package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.nine.pros.post.biz.mapper.TagMapper;
import cn.nine.pros.post.biz.model.domain.TagDomain;
import cn.nine.pros.post.biz.model.mapstruct.TagMapstruct;
import cn.nine.pros.post.biz.service.base.TagService;
import cn.nine.pros.post.client.model.db.TagDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 兴趣标签表 ServiceImpl
 *
 * @author Administrator
 */
@Service
public class TagServiceImpl extends ServiceImpl<TagMapper, TagDomain>
        implements TagService {

    @Autowired
    private TagMapstruct tagMapstruct;

    @Override
    public void upsert(TagDTO tagDTO) {
        Integer id = tagDTO.getId();
        if (id == null) {
            TagDomain domain = tagMapstruct.toDomain(tagDTO);
            domain.initAudit(MyRequestContextHolder.userId());
            save(domain);
            return;
        }
        TagDomain domain = tagMapstruct.toDomain(tagDTO);
        domain.setId(id);
        domain.setUpdatedAt(LocalDateTime.now());
        domain.setUpdatedBy(MyRequestContextHolder.userId());
        updateById(domain);
    }

    @Override
    public TagDTO findById(Integer id) {
        return tagMapstruct.toDTO(getById(id));
    }

    @Override
    public void delByIds(List<Integer> ids) {
        TagDomain tagDomain = new TagDomain();
        tagDomain.setDelFlag(true);
        tagDomain.setUpdatedAt(LocalDateTime.now());
        update(tagDomain, new LambdaQueryWrapper<TagDomain>()
                .in(TagDomain::getId, ids));
    }

    @Override
    public List<TagDomain> listActiveByLang(String langCode) {
        return list(new LambdaQueryWrapper<TagDomain>()
                .eq(TagDomain::isDelFlag, false)
                .eq(TagDomain::getLangCode, langCode)
                .orderByAsc(TagDomain::getSortOrder)
                .orderByAsc(TagDomain::getId));
    }

}