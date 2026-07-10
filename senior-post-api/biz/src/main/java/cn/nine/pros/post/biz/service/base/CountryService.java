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

    /** 未删除国家，按 sort_order、id 升序。 */
    List<CountryDomain> listActiveOrdered();

    /** 按 country_code 取未删除国家（忽略大小写）。 */
    CountryDomain findActiveByCode(String countryCode);


    com.baomidou.mybatisplus.extension.plugins.pagination.Page<CountryDomain> pageForAdmin(
            cn.nine.commons.data.page.PageQuery pageQuery, String countryCode, String keyword);

}