package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.nine.pros.post.biz.mapper.LoginMapper;
import cn.nine.pros.post.biz.model.domain.LoginDomain;
import cn.nine.pros.post.biz.model.mapstruct.LoginMapstruct;
import cn.nine.pros.post.biz.service.base.LoginService;
import cn.nine.pros.post.client.model.db.LoginDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 登录日志表 ServiceImpl
 *
 * @author Administrator
 */
@Service
public class LoginServiceImpl extends ServiceImpl<LoginMapper, LoginDomain>
        implements LoginService {

    @Autowired
    private LoginMapstruct loginMapstruct;

    @Override
    public void upsert(LoginDTO loginDTO) {
        Long id = loginDTO.getId();
        if (id == null) {
            LoginDomain domain = loginMapstruct.toDomain(loginDTO);
            domain.initAudit(MyRequestContextHolder.userId());
            save(domain);
            return;
        }
        LoginDomain domain = loginMapstruct.toDomain(loginDTO);
        domain.setId(id);
        domain.setUpdatedAt(LocalDateTime.now());
        domain.setUpdatedBy(MyRequestContextHolder.userId());
        updateById(domain);
    }

    @Override
    public LoginDTO findById(Long id) {
        return loginMapstruct.toDTO(getById(id));
    }

    @Override
    public void delByIds(List<Long> ids) {
        LoginDomain loginDomain = new LoginDomain();
        loginDomain.setDelFlag(true);
        loginDomain.setUpdatedAt(LocalDateTime.now());
        update(loginDomain, new LambdaQueryWrapper<LoginDomain>()
                .in(LoginDomain::getId, ids));
    }

}