package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.ActionDomain;
import com.baomidou.mybatisplus.extension.service.IService;
import cn.nine.pros.post.client.model.db.ActionDTO;

import java.util.List;

/**
 * 用户行为日志（发布/寄信/加速等） Service
 *
 * @author Administrator
 */
public interface ActionService extends IService<ActionDomain> {

    void upsert(ActionDTO actionDTO);

    ActionDTO findById(Long id);

    void delByIds(List<Long> ids);

}