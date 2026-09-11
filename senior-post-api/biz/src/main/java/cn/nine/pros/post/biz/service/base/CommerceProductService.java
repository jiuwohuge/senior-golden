package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.CommerceProductDomain;
import com.baomidou.mybatisplus.extension.service.IService;

import java.util.List;

public interface CommerceProductService extends IService<CommerceProductDomain> {

    List<CommerceProductDomain> listActiveByType(String type);

    CommerceProductDomain findByCode(String code);

    /** 按商品编码查找（含下架，供管理端筛选）。 */
    CommerceProductDomain findByCodeAnyStatus(String code);

    /** 按权益码查找上架商品（如 entitlement_code=plus）。 */
    CommerceProductDomain findByEntitlementCode(String entitlementCode);

    List<CommerceProductDomain> listAllActive();

    com.baomidou.mybatisplus.extension.plugins.pagination.Page<CommerceProductDomain> pageForAdmin(
            cn.nine.commons.data.page.PageQuery pageQuery, String productType, Integer status);

    CommerceProductDomain upsertFromAdmin(CommerceProductDomain row, Long actorId);

    /** 批量更新商品状态。 */
    void batchUpdateStatus(java.util.Collection<Long> ids, int status, Long actorId);
}
