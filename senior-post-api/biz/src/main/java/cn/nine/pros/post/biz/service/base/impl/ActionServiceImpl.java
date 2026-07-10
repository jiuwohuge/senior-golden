package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.pros.post.biz.support.PageQueryNormalize;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.nine.pros.post.biz.mapper.ActionMapper;
import cn.nine.pros.post.biz.model.domain.ActionDomain;
import cn.nine.pros.post.biz.model.mapstruct.ActionMapstruct;
import cn.nine.pros.post.biz.service.base.ActionService;
import cn.nine.pros.post.client.model.db.ActionDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 用户行为日志（发布/寄信/加速等） ServiceImpl
 *
 * @author Administrator
 */
@Service
public class ActionServiceImpl extends ServiceImpl<ActionMapper, ActionDomain>
        implements ActionService {

    @Autowired
    private ActionMapstruct actionMapstruct;

    @Override
    public void upsert(ActionDTO actionDTO) {
        Long id = actionDTO.getId();
        if (id == null) {
            ActionDomain domain = actionMapstruct.toDomain(actionDTO);
            domain.initAudit(MyRequestContextHolder.userId());
            save(domain);
            return;
        }
        ActionDomain domain = actionMapstruct.toDomain(actionDTO);
        domain.setId(id);
        domain.setUpdatedAt(LocalDateTime.now());
        domain.setUpdatedBy(MyRequestContextHolder.userId());
        updateById(domain);
    }

    @Override
    public ActionDTO findById(Long id) {
        return actionMapstruct.toDTO(getById(id));
    }

    @Override
    public void delByIds(List<Long> ids) {
        ActionDomain actionDomain = new ActionDomain();
        actionDomain.setDelFlag(true);
        actionDomain.setUpdatedAt(LocalDateTime.now());
        update(actionDomain, new LambdaQueryWrapper<ActionDomain>()
                .in(ActionDomain::getId, ids));
    }


    @Override
    public com.baomidou.mybatisplus.extension.plugins.pagination.Page<ActionDomain> pageForAdmin(
            cn.nine.commons.data.page.PageQuery pageQuery, Long userId, String actionType) {
        LambdaQueryWrapper<ActionDomain> qw = new LambdaQueryWrapper<ActionDomain>()
                .eq(ActionDomain::isDelFlag, false)
                .orderByDesc(ActionDomain::getCreatedAt);
        if (userId != null) {
            qw.eq(ActionDomain::getUserId, userId);
        }
        if (actionType != null && !actionType.isBlank()) {
            qw.eq(ActionDomain::getActionType, actionType.trim());
        }
        return page(PageQueryNormalize.mpPage(pageQuery, PageQueryNormalize.ADMIN_MAX_SIZE), qw);
    }

}