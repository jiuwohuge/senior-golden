package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.UserTagDomain;
import com.baomidou.mybatisplus.extension.service.IService;
import cn.nine.pros.post.client.model.db.UserTagDTO;

import java.util.List;

/**
 * 用户兴趣标签关联表 Service
 *
 * @author Administrator
 */
public interface UserTagService extends IService<UserTagDomain> {

    void upsert(UserTagDTO userTagDTO);

    UserTagDTO findById(Long id);

    void delByIds(List<Long> ids);

}