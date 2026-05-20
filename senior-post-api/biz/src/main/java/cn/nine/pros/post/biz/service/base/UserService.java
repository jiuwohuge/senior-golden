package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.UserDomain;
import com.baomidou.mybatisplus.extension.service.IService;
import cn.nine.pros.post.client.model.db.UserDTO;

import java.util.List;

/**
 * 用户主表 Service
 */
public interface UserService extends IService<UserDomain> {

    void upsert(UserDTO userDTO);

    UserDTO findById(Long id);

    void delByIds(List<Long> ids);

    /**
     * 按邮箱 identity 查询未删除用户；不存在返回 null。
     */
    UserDTO findByEmail(String email);

    /**
     * 与名录可列出 App 用户口径一致：del_flag=false, status=1, staff_role=0。
     */
    long countActiveAppUsers();
}
