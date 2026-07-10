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


    com.baomidou.mybatisplus.extension.plugins.pagination.Page<cn.nine.pros.post.biz.model.domain.ActionDomain> pageForAdmin(
            cn.nine.commons.data.page.PageQuery pageQuery, Long userId, String actionType);

    /**
     * 记录行为事件（§14）；details 可为 null。
     */
    void recordEvent(long userId, String actionType, String targetType, Long targetId, String detailsJson);

    /** 用户自 since 起是否有任意行为（匹配活跃过滤可选）。 */
    boolean existsRecentAction(long userId, java.time.LocalDateTime since);

}