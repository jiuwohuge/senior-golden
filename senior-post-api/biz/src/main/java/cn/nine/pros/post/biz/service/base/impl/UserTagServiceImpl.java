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
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
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
        Set<Integer> unique = collectDistinctTagIds(distinctTagIds);

        List<UserTagDomain> existingRows = getBaseMapper().selectAllByUserIdIncludingDeleted(userId);
        Map<Integer, UserTagDomain> byTagId = new HashMap<>();
        for (UserTagDomain row : existingRows) {
            if (row.getTagId() != null && !byTagId.containsKey(row.getTagId())) {
                byTagId.put(row.getTagId(), row);
            }
        }

        LocalDateTime now = LocalDateTime.now();
        for (UserTagDomain row : existingRows) {
            softDeleteIfRemoved(row, unique, actorUserId, now);
        }

        for (Integer tagId : unique) {
            upsertActiveTag(byTagId.get(tagId), tagId, userId, actorUserId, now);
        }
    }

    private static Set<Integer> collectDistinctTagIds(List<Integer> distinctTagIds) {
        Set<Integer> unique = new LinkedHashSet<>();
        if (distinctTagIds == null) {
            return unique;
        }
        for (Integer id : distinctTagIds) {
            if (id != null) {
                unique.add(id);
            }
        }
        return unique;
    }

    private void softDeleteIfRemoved(UserTagDomain row, Set<Integer> unique, long actorUserId, LocalDateTime now) {
        Integer tagId = row.getTagId();
        if (tagId == null || !Boolean.FALSE.equals(row.isDelFlag())) {
            return;
        }
        if (unique.contains(tagId)) {
            return;
        }
        row.setDelFlag(true);
        row.setUpdatedAt(now);
        row.setUpdatedBy(actorUserId);
        updateById(row);
    }

    private void upsertActiveTag(UserTagDomain existing, Integer tagId, long userId, long actorUserId, LocalDateTime now) {
        if (existing == null) {
            UserTagDomain insertRow = new UserTagDomain();
            insertRow.setUserId(userId);
            insertRow.setTagId(tagId);
            insertRow.initAudit(actorUserId);
            save(insertRow);
            return;
        }
        if (!Boolean.TRUE.equals(existing.isDelFlag())) {
            return;
        }
        existing.setDelFlag(false);
        existing.setUpdatedAt(now);
        existing.setUpdatedBy(actorUserId);
        getBaseMapper().restoreById(existing.getId(), now, actorUserId);
    }


    @Override
    public List<Integer> listTagIdsByUserId(long userId) {
        return list(new LambdaQueryWrapper<UserTagDomain>()
                        .eq(UserTagDomain::getUserId, userId)
                        .eq(UserTagDomain::isDelFlag, false))
                .stream()
                .map(UserTagDomain::getTagId)
                .toList();
    }

}