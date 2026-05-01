package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.ExceptionDomain;
import com.baomidou.mybatisplus.extension.service.IService;
import cn.nine.pros.post.client.model.db.ExceptionDTO;

import java.util.List;

/**
 * 系统异常日志表 Service
 *
 * @author Administrator
 */
public interface ExceptionService extends IService<ExceptionDomain> {

    void upsert(ExceptionDTO exceptionDTO);

    ExceptionDTO findById(Long id);

    void delByIds(List<Long> ids);

}