package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.TagDomain;
import com.baomidou.mybatisplus.extension.service.IService;
import cn.nine.pros.post.client.model.db.TagDTO;

import java.util.List;

/**
 * 兴趣标签表 Service
 *
 * @author Administrator
 */
public interface TagService extends IService<TagDomain> {

    void upsert(TagDTO tagDTO);

    TagDTO findById(Integer id);

    void delByIds(List<Integer> ids);

    List<TagDomain> listActiveByLang(String langCode);

}
