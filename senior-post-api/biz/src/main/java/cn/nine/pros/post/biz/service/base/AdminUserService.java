package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.AdminUserDomain;
import com.baomidou.mybatisplus.extension.service.IService;
import cn.nine.pros.post.client.model.db.AdminUserDTO;

import java.util.List;

/**
 * 管理员表 Service
 *
 * @author Administrator
 */
public interface AdminUserService extends IService<AdminUserDomain> {

    void upsert(AdminUserDTO adminUserDTO);

    AdminUserDTO findById(Long id);

    void delByIds(List<Long> ids);

}