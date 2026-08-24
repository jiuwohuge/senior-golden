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

    /**
     * 兴趣标签（tag_kind=interest），不含写信主题邮票。
     */
    List<TagDomain> listActiveByLang(String langCode);

    /**
     * 写信主题邮票（tag_kind=letter_topic），按 sort_order。
     */
    List<TagDomain> listActiveLetterTopicsByLang(String langCode);

}
