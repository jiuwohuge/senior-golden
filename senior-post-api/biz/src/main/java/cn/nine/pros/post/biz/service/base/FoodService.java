package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.FoodDomain;
import com.baomidou.mybatisplus.extension.service.IService;
import cn.nine.pros.post.client.model.db.FoodDTO;

import java.util.List;

/**
 * ${classComments} Service
 *
 * @author Administrator
 */
public interface FoodService extends IService<FoodDomain> {

    void upsert(FoodDTO foodDTO);

    FoodDTO findById(Long id);

    void delByIds(List<Long> ids);

}