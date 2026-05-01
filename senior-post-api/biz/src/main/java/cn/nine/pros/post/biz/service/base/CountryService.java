package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.CountryDomain;
import com.baomidou.mybatisplus.extension.service.IService;
import cn.nine.pros.post.client.model.db.CountryDTO;

import java.util.List;

/**
 * 国家地区表 Service
 *
 * @author Administrator
 */
public interface CountryService extends IService<CountryDomain> {

    void upsert(CountryDTO countryDTO);

    CountryDTO findById(Integer id);

    void delByIds(List<Integer> ids);

}