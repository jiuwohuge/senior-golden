package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.CommerceProductChannelDomain;
import com.baomidou.mybatisplus.extension.service.IService;

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
}
