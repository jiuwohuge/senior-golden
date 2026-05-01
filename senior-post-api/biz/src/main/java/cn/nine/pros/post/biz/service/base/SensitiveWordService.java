package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.SensitiveWordDomain;
import com.baomidou.mybatisplus.extension.service.IService;
import cn.nine.pros.post.client.model.db.SensitiveWordDTO;

import java.util.List;

/**
 * 敏感词库表 Service
 *
 * @author Administrator
 */
public interface SensitiveWordService extends IService<SensitiveWordDomain> {

    void upsert(SensitiveWordDTO sensitiveWordDTO);

    SensitiveWordDTO findById(Integer id);

    void delByIds(List<Integer> ids);

}