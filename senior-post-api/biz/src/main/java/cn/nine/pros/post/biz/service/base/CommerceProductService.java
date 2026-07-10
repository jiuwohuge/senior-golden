package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.CommerceProductDomain;
import com.baomidou.mybatisplus.extension.service.IService;

import java.util.List;

public interface CommerceProductService extends IService<CommerceProductDomain> {

    List<CommerceProductDomain> listActiveByType(String type);

    CommerceProductDomain findByCode(String code);

    List<CommerceProductDomain> listAllActive();

    com.baomidou.mybatisplus.extension.plugins.pagination.Page<CommerceProductDomain> pageForAdmin(
            cn.nine.commons.data.page.PageQuery pageQuery, String productType);

    CommerceProductDomain upsertFromAdmin(CommerceProductDomain row, Long actorId);
}
