package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.PostcardDomain;
import com.baomidou.mybatisplus.extension.service.IService;
import cn.nine.pros.post.client.model.db.PostcardDTO;

import java.util.List;

/**
 * 明信片墙表（用户发布的公开明信片） Service
 *
 * @author Administrator
 */
public interface PostcardService extends IService<PostcardDomain> {

    void upsert(PostcardDTO postcardDTO);

    PostcardDTO findById(Long id);

    void delByIds(List<Long> ids);

}