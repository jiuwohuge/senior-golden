package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.CommerceProductChannelDomain;
import com.baomidou.mybatisplus.extension.service.IService;

import java.util.Collection;
import java.util.List;

/**
 * 商品渠道映射 Base Service。
 */
public interface CommerceProductChannelService extends IService<CommerceProductChannelDomain> {

    /**
     * 按 provider + storeProductId + environment 查找启用中的渠道行。
     */
    CommerceProductChannelDomain findByProviderAndStoreProductId(
            String provider, String storeProductId, String environment);

    /**
     * 按 provider + storeProductId 查找（优先 sandbox，再任意启用行）。
     */
    CommerceProductChannelDomain findByProviderAndStoreProductId(String provider, String storeProductId);

    /**
     * 某商品下未删除的渠道列表。
     */
    List<CommerceProductChannelDomain> listByProductId(Long productId);

    /**
     * 批量按商品 ID 加载未删除渠道。
     */
    List<CommerceProductChannelDomain> listByProductIds(Collection<Long> productIds);

    /**
     * 管理端保存：按 id 或 provider+storeProductId+environment upsert；未出现在列表中的行软删。
     */
    void upsertChannelsForProduct(Long productId, List<CommerceProductChannelDomain> channels, Long actorId);
}
