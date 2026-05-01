package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.ConfigDomain;
import com.baomidou.mybatisplus.extension.service.IService;
import cn.nine.pros.post.client.model.db.ConfigDTO;

import java.util.List;

/**
 * 系统配置表 Service
 *
 * @author Administrator
 */
public interface ConfigService extends IService<ConfigDomain> {

    void upsert(ConfigDTO configDTO);

    ConfigDTO findById(Integer id);

    void delByIds(List<Integer> ids);

}