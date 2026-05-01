package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.ImMessageDomain;
import com.baomidou.mybatisplus.extension.service.IService;
import cn.nine.pros.post.client.model.db.ImMessageDTO;

import java.util.List;

/**
 * IM消息表 Service
 *
 * @author Administrator
 */
public interface ImMessageService extends IService<ImMessageDomain> {

    void upsert(ImMessageDTO imMessageDTO);

    ImMessageDTO findById(Long id);

    void delByIds(List<Long> ids);

}