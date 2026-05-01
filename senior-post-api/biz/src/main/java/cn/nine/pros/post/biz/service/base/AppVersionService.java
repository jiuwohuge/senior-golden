package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.AppVersionDomain;
import com.baomidou.mybatisplus.extension.service.IService;
import cn.nine.pros.post.client.model.db.AppVersionDTO;

import java.util.List;

/**
 * App版本控制表 Service
 *
 * @author Administrator
 */
public interface AppVersionService extends IService<AppVersionDomain> {

    void upsert(AppVersionDTO appVersionDTO);

    AppVersionDTO findById(Integer id);

    void delByIds(List<Integer> ids);

}