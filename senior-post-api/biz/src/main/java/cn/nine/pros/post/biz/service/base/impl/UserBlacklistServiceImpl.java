package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
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

}