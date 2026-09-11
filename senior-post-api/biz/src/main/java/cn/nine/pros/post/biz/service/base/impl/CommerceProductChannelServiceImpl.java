package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.pros.post.biz.mapper.CommerceProductChannelMapper;
import cn.nine.pros.post.biz.model.domain.CommerceProductChannelDomain;
import cn.nine.pros.post.biz.service.base.CommerceProductChannelService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

/**
 * 商品渠道映射 ServiceImpl。
 */
@Service
public class CommerceProductChannelServiceImpl
        extends ServiceImpl<CommerceProductChannelMapper, CommerceProductChannelDomain>
        implements CommerceProductChannelService {

    private static final int STATUS_ACTIVE = 1;
    private static final String ENV_SANDBOX = "sandbox";

    @Override
    public CommerceProductChannelDomain findByProviderAndStoreProductId(
            String provider, String storeProductId, String environment) {
        if (!StringUtils.hasText(provider) || !StringUtils.hasText(storeProductId)) {
            return null;
        }
        LambdaQueryWrapper<CommerceProductChannelDomain> qw = activeWrapper(provider, storeProductId);
        if (StringUtils.hasText(environment)) {
            qw.eq(CommerceProductChannelDomain::getEnvironment, environment.trim());
        }
        return getOne(qw.last("LIMIT 1"));
    }

    @Override
    public CommerceProductChannelDomain findByProviderAndStoreProductId(String provider, String storeProductId) {
        CommerceProductChannelDomain sandbox = findByProviderAndStoreProductId(provider, storeProductId, ENV_SANDBOX);
        if (sandbox != null) {
            return sandbox;
        }
        if (!StringUtils.hasText(provider) || !StringUtils.hasText(storeProductId)) {
            return null;
        }
        return getOne(activeWrapper(provider, storeProductId)
                .orderByDesc(CommerceProductChannelDomain::getUpdatedAt)
                .last("LIMIT 1"));
    }

    private LambdaQueryWrapper<CommerceProductChannelDomain> activeWrapper(String provider, String storeProductId) {
        return new LambdaQueryWrapper<CommerceProductChannelDomain>()
                .eq(CommerceProductChannelDomain::getProvider, provider.trim())
                .eq(CommerceProductChannelDomain::getStoreProductId, storeProductId.trim())
                .eq(CommerceProductChannelDomain::getStatus, STATUS_ACTIVE)
                .eq(CommerceProductChannelDomain::isDelFlag, false);
    }
}
