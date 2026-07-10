package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.pros.post.biz.support.PageQueryNormalize;
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

    @Override
    public List<LoginDomain> listRecentSuccessfulByUserId(long userId, int limit) {
        return list(new LambdaQueryWrapper<LoginDomain>()
                .eq(LoginDomain::getUserId, userId)
                .eq(LoginDomain::getLoginResult, 1)
                .orderByDesc(LoginDomain::getId)
                .last("LIMIT " + Math.max(1, limit)));
    }


    @Override
    public com.baomidou.mybatisplus.extension.plugins.pagination.Page<LoginDomain> pageForAdmin(
            cn.nine.commons.data.page.PageQuery pageQuery, Long userId, Integer loginResult) {
        LambdaQueryWrapper<LoginDomain> qw = new LambdaQueryWrapper<LoginDomain>()
                .eq(LoginDomain::isDelFlag, false)
                .orderByDesc(LoginDomain::getCreatedAt);
        if (userId != null) {
            qw.eq(LoginDomain::getUserId, userId);
        }
        if (loginResult != null) {
            qw.eq(LoginDomain::getLoginResult, loginResult);
        }
        return page(PageQueryNormalize.mpPage(pageQuery, PageQueryNormalize.ADMIN_MAX_SIZE), qw);
    }

}