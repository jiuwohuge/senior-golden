package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.UserBlacklistDomain;
import com.baomidou.mybatisplus.extension.service.IService;
import cn.nine.pros.post.client.model.db.UserBlacklistDTO;

import java.util.List;

/**
 * 用户黑名单表 Service
 *
 * @author Administrator
 */
public interface UserBlacklistService extends IService<UserBlacklistDomain> {

    void upsert(UserBlacklistDTO userBlacklistDTO);

    UserBlacklistDTO findById(Long id);

    void delByIds(List<Long> ids);

}