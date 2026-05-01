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

}