package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.LoginDomain;
import com.baomidou.mybatisplus.extension.service.IService;
import cn.nine.pros.post.client.model.db.LoginDTO;

import java.util.List;

/**
 * 登录日志表 Service
 *
 * @author Administrator
 */
public interface LoginService extends IService<LoginDomain> {

    void upsert(LoginDTO loginDTO);

    LoginDTO findById(Long id);

    void delByIds(List<Long> ids);

    /** 用户最近成功登录记录（login_result=1）。 */
    List<LoginDomain> listRecentSuccessfulByUserId(long userId, int limit);


    com.baomidou.mybatisplus.extension.plugins.pagination.Page<LoginDomain> pageForAdmin(
            cn.nine.commons.data.page.PageQuery pageQuery, Long userId, Integer loginResult);

}