package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.nine.pros.post.biz.mapper.UserTagMapper;
import cn.nine.pros.post.biz.model.domain.UserTagDomain;
import cn.nine.pros.post.biz.model.mapstruct.UserTagMapstruct;
import cn.nine.pros.post.biz.service.base.UserTagService;
import cn.nine.pros.post.client.model.db.UserTagDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

/**
 * 用户兴趣标签关联表 ServiceImpl
 *
 * @author Administrator
 */
@Service
public class UserTagServiceImpl extends ServiceImpl<UserTagMapper, UserTagDomain>
        implements UserTagService {

    @Autowired
    private UserTagMapstruct userTagMapstruct;

    @Override
    public void upsert(UserTagDTO userTagDTO) {
        Long id = userTagDTO.getId();
        if (id == null) {
            UserTagDomain domain = userTagMapstruct.toDomain(userTagDTO);
            domain.initAudit(MyRequestContextHolder.userId());
            save(domain);
            return;
        }
        UserTagDomain domain = userTagMapstruct.toDomain(userTagDTO);
        domain.setId(id);
        domain.setUpdatedAt(LocalDateTime.now());
        domain.setUpdatedBy(MyRequestContextHolder.userId());
        updateById(domain);
    }

    @Override
    public UserTagDTO findById(Long id) {
        return userTagMapstruct.toDTO(getById(id));
    }

    @Override
    public void delByIds(List<Long> ids) {
        UserTagDomain userTagDomain = new UserTagDomain();
        userTagDomain.setDelFlag(true);
        userTagDomain.setUpdatedAt(LocalDateTime.now());
        update(userTagDomain, new LambdaQueryWrapper<UserTagDomain>()
                .in(UserTagDomain::getId, ids));
    }

    @Override
    public void replaceUserTags(long actorUserId, long userId, List<Integer> distinctTagIds) {
        Set<Integer> unique = new LinkedHashSet<>();
        if (distinctTagIds != null) {
            for (Integer id : distinctTagIds) {
                if (id != null) {
                    unique.add(id);
                }
            }
        }
        UserTagDomain soft = new UserTagDomain();
        soft.setDelFlag(true);
        soft.setUpdatedAt(LocalDateTime.now());
        soft.setUpdatedBy(actorUserId);
        update(soft, new LambdaQueryWrapper<UserTagDomain>()
                .eq(UserTagDomain::getUserId, userId)
                .eq(UserTagDomain::isDelFlag, false));
        for (Integer tagId : unique) {
            UserTagDomain row = new UserTagDomain();
            row.setUserId(userId);
            row.setTagId(tagId);
            row.initAudit(actorUserId);
            save(row);
        }
    }

}