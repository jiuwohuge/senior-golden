package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.ImConversationDomain;
import com.baomidou.mybatisplus.extension.service.IService;
import cn.nine.pros.post.client.model.db.ImConversationDTO;

import java.util.List;

/**
 * IM会话表（腾讯IM） Service
 *
 * @author Administrator
 */
public interface ImConversationService extends IService<ImConversationDomain> {

    void upsert(ImConversationDTO imConversationDTO);

    ImConversationDTO findById(Long id);

    void delByIds(List<Long> ids);

}