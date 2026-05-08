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

    /**
     * 用户生成内容发布前校验：命中 {@code sys_sensitive_word} 中未删除词条则抛出业务异常。
     */
    void assertPlainTextAllowed(String text);

}