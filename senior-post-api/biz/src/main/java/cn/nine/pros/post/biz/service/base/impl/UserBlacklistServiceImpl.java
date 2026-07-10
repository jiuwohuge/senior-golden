package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.nine.pros.post.biz.mapper.UserBlacklistMapper;
import cn.nine.pros.post.biz.model.domain.UserBlacklistDomain;
import cn.nine.pros.post.biz.model.mapstruct.UserBlacklistMapstruct;
import cn.nine.pros.post.biz.service.base.UserBlacklistService;
import cn.nine.pros.post.client.model.db.UserBlacklistDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 用户黑名单表 ServiceImpl
 *
 * @author Administrator
 */
@Service
public class UserBlacklistServiceImpl extends ServiceImpl<UserBlacklistMapper, UserBlacklistDomain>
        implements UserBlacklistService {

    @Autowired
    private UserBlacklistMapstruct userBlacklistMapstruct;

    @Override
    public void upsert(UserBlacklistDTO userBlacklistDTO) {
        Long id = userBlacklistDTO.getId();
        if (id == null) {
            UserBlacklistDomain domain = userBlacklistMapstruct.toDomain(userBlacklistDTO);
            domain.initAudit(MyRequestContextHolder.userId());
            save(domain);
            return;
        }
        UserBlacklistDomain domain = userBlacklistMapstruct.toDomain(userBlacklistDTO);
        domain.setId(id);
        domain.setUpdatedAt(LocalDateTime.now());
        domain.setUpdatedBy(MyRequestContextHolder.userId());
        updateById(domain);
    }

    @Override
    public UserBlacklistDTO findById(Long id) {
        return userBlacklistMapstruct.toDTO(getById(id));
    }

    @Override
    public void delByIds(List<Long> ids) {
        UserBlacklistDomain userBlacklistDomain = new UserBlacklistDomain();
        userBlacklistDomain.setDelFlag(true);
        userBlacklistDomain.setUpdatedAt(LocalDateTime.now());
        update(userBlacklistDomain, new LambdaQueryWrapper<UserBlacklistDomain>()
                .in(UserBlacklistDomain::getId, ids));
    }

    @Override
    public UserBlacklistDomain findByPair(long userId, long blockedUserId) {
        return getOne(new LambdaQueryWrapper<UserBlacklistDomain>()
                .eq(UserBlacklistDomain::getUserId, userId)
                .eq(UserBlacklistDomain::getBlockedUserId, blockedUserId));
    }

    @Override
    public List<UserBlacklistDomain> listActiveByUserId(long userId) {
        return list(new LambdaQueryWrapper<UserBlacklistDomain>()
                .eq(UserBlacklistDomain::getUserId, userId)
                .eq(UserBlacklistDomain::isDelFlag, false)
                .orderByDesc(UserBlacklistDomain::getCreatedAt));
    }

    @Override
    public boolean softUnblock(long userId, long blockedUserId) {
        return update(null, new LambdaUpdateWrapper<UserBlacklistDomain>()
                .eq(UserBlacklistDomain::getUserId, userId)
                .eq(UserBlacklistDomain::getBlockedUserId, blockedUserId)
                .eq(UserBlacklistDomain::isDelFlag, false)
                .set(UserBlacklistDomain::isDelFlag, true)
                .set(UserBlacklistDomain::getUpdatedAt, LocalDateTime.now())
                .set(UserBlacklistDomain::getUpdatedBy, userId));
    }

    @Override
    public boolean existsActiveBlock(long blockerUserId, long blockedUserId) {
        return count(new LambdaQueryWrapper<UserBlacklistDomain>()
                .eq(UserBlacklistDomain::getUserId, blockerUserId)
                .eq(UserBlacklistDomain::getBlockedUserId, blockedUserId)
                .eq(UserBlacklistDomain::isDelFlag, false)) > 0;
    }

}