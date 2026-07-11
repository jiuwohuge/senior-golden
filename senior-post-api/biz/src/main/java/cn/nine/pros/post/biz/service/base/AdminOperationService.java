package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.AdminOperationDomain;
import com.baomidou.mybatisplus.extension.service.IService;
import cn.nine.pros.post.client.model.db.AdminOperationDTO;

import java.util.List;

/**
 * 管理员操作日志表 Service
 *
 * @author Administrator
 */
public interface AdminOperationService extends IService<AdminOperationDomain> {

    void upsert(AdminOperationDTO adminOperationDTO);

    AdminOperationDTO findById(Long id);

    void delByIds(List<Long> ids);

    /**
     * 写入一条管理员操作日志。
     */
    void record(long adminId, String actionType, String targetType, Long targetId, String details, String ip);

    /**
     * 管理端分页查询操作日志。
     */
    com.baomidou.mybatisplus.extension.plugins.pagination.Page<AdminOperationDomain> pageForAdmin(
            cn.nine.commons.data.page.PageQuery pageQuery,
            Long adminId, String actionType, String targetType);

}
