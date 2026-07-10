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

    /** 软删用户既有标签关联后，按顺序插入新关联。 */
    void replaceUserTags(long actorUserId, long userId, List<Integer> distinctTagIds);

    List<Integer> listTagIdsByUserId(long userId);
}
