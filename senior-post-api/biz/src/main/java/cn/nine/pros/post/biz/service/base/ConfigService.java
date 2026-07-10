package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.ConfigDomain;
import com.baomidou.mybatisplus.extension.service.IService;
import cn.nine.pros.post.client.model.db.ConfigDTO;

import java.util.Collection;
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

    /** 按 config_key 取未删除配置（最多一条）。 */
    ConfigDomain findActiveByKey(String configKey);

    /** 按多个 key 取未删除配置。 */
    List<ConfigDomain> listActiveByKeys(Collection<String> configKeys);

    /** 读取整型配置；缺失或非法时返回 defaultValue。 */
    int getInt(String configKey, int defaultValue);

    /** 读取浮点配置；缺失或非法时返回 defaultValue。 */
    double getDouble(String configKey, double defaultValue);


    com.baomidou.mybatisplus.extension.plugins.pagination.Page<ConfigDomain> pageForAdmin(
            cn.nine.commons.data.page.PageQuery pageQuery, String configGroup);

}
