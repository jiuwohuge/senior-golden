package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.StampTransactionDomain;
import com.baomidou.mybatisplus.extension.service.IService;
import cn.nine.pros.post.client.model.db.StampTransactionDTO;

import java.util.List;

/**
 * 邮票变更流水日志 Service
 *
 * @author Administrator
 */
public interface StampTransactionService extends IService<StampTransactionDomain> {

    void upsert(StampTransactionDTO stampTransactionDTO);

    StampTransactionDTO findById(Long id);

    void delByIds(List<Long> ids);

}