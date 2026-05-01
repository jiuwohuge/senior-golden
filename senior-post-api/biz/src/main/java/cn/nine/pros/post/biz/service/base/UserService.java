package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.UserDomain;
import com.baomidou.mybatisplus.extension.service.IService;
import cn.nine.pros.post.client.model.db.UserDTO;

import java.util.List;

/**
 * 用户主表 Service
 *
 * @author Administrator
 */
public interface UserService extends IService<UserDomain> {

    void upsert(UserDTO userDTO);

    UserDTO findById(Long id);

    void delByIds(List<Long> ids);

    /**
     * 按邮箱查询未删除用户；不存在返回 null。
     */
    UserDTO findByEmail(String email);

}