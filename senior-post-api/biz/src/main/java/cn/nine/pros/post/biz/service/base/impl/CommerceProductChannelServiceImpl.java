package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.pros.post.biz.mapper.CommerceProductChannelMapper;
import cn.nine.pros.post.biz.model.domain.CommerceProductChannelDomain;
import cn.nine.pros.post.biz.service.base.CommerceProductChannelService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * 商品渠道映射 ServiceImpl。
 */
@Slf4j
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

    @Override
    public List<CommerceProductChannelDomain> listByProductId(Long productId) {
        if (productId == null) {
            return List.of();
        }
        return list(new LambdaQueryWrapper<CommerceProductChannelDomain>()
                .eq(CommerceProductChannelDomain::getProductId, productId)
                .eq(CommerceProductChannelDomain::isDelFlag, false)
                .orderByAsc(CommerceProductChannelDomain::getId));
    }

    @Override
    public List<CommerceProductChannelDomain> listByProductIds(Collection<Long> productIds) {
        if (productIds == null || productIds.isEmpty()) {
            return List.of();
        }
        return list(new LambdaQueryWrapper<CommerceProductChannelDomain>()
                .in(CommerceProductChannelDomain::getProductId, productIds)
                .eq(CommerceProductChannelDomain::isDelFlag, false)
                .orderByAsc(CommerceProductChannelDomain::getProductId)
                .orderByAsc(CommerceProductChannelDomain::getId));
    }

    /**
     * 按 id 优先，否则按 provider+storeProductId+environment 匹配后 upsert；缺席渠道软删。
     */
    @Override
    public void upsertChannelsForProduct(Long productId, List<CommerceProductChannelDomain> channels, Long actorId) {
        if (productId == null) {
            return;
        }
        Long auditUserId = actorId != null ? actorId : 0L;
        List<CommerceProductChannelDomain> incoming = channels != null ? channels : List.of();
        List<CommerceProductChannelDomain> existing = listByProductId(productId);
        Set<Long> keepIds = new HashSet<>();

        for (CommerceProductChannelDomain row : incoming) {
            if (row == null || !StringUtils.hasText(row.getProvider()) || !StringUtils.hasText(row.getStoreProductId())) {
                continue;
            }
            CommerceProductChannelDomain target = resolveExisting(existing, row);
            if (target == null) {
                CommerceProductChannelDomain created = new CommerceProductChannelDomain();
                copyChannelFields(created, row, productId);
                created.initAudit(auditUserId);
                if (created.getStatus() == null) {
                    created.setStatus(STATUS_ACTIVE);
                }
                save(created);
                keepIds.add(created.getId());
                log.info("commerce channel created, id={}, productId={}, provider={}, storeProductId={}",
                        created.getId(), productId, created.getProvider(), created.getStoreProductId());
                continue;
            }
            copyChannelFields(target, row, productId);
            target.updateAudit(auditUserId);
            updateById(target);
            keepIds.add(target.getId());
            log.info("commerce channel updated, id={}, productId={}, provider={}",
                    target.getId(), productId, target.getProvider());
        }

        for (CommerceProductChannelDomain old : existing) {
            if (keepIds.contains(old.getId())) {
                continue;
            }
            old.markDeleted(auditUserId);
            updateById(old);
            log.info("commerce channel soft-deleted, id={}, productId={}", old.getId(), productId);
        }
    }

    private CommerceProductChannelDomain resolveExisting(
            List<CommerceProductChannelDomain> existing, CommerceProductChannelDomain row) {
        if (row.getId() != null) {
            for (CommerceProductChannelDomain e : existing) {
                if (row.getId().equals(e.getId())) {
                    return e;
                }
            }
        }
        String provider = row.getProvider().trim();
        String storeProductId = row.getStoreProductId().trim();
        String environment = StringUtils.hasText(row.getEnvironment()) ? row.getEnvironment().trim() : "";
        for (CommerceProductChannelDomain e : existing) {
            if (!provider.equals(e.getProvider())) {
                continue;
            }
            if (!storeProductId.equals(e.getStoreProductId())) {
                continue;
            }
            String env = e.getEnvironment() != null ? e.getEnvironment() : "";
            if (environment.equals(env)) {
                return e;
            }
        }
        return null;
    }

    private static void copyChannelFields(
            CommerceProductChannelDomain target, CommerceProductChannelDomain src, Long productId) {
        target.setProductId(productId);
        target.setProvider(src.getProvider().trim());
        target.setStoreProductId(src.getStoreProductId().trim());
        target.setBasePlanId(src.getBasePlanId());
        target.setOfferId(src.getOfferId());
        target.setAppIdOrPackageName(src.getAppIdOrPackageName());
        if (StringUtils.hasText(src.getEnvironment())) {
            target.setEnvironment(src.getEnvironment().trim());
        }
        if (src.getStatus() != null) {
            target.setStatus(src.getStatus());
        }
        target.setProviderConfigJson(src.getProviderConfigJson());
    }

    private LambdaQueryWrapper<CommerceProductChannelDomain> activeWrapper(String provider, String storeProductId) {
        return new LambdaQueryWrapper<CommerceProductChannelDomain>()
                .eq(CommerceProductChannelDomain::getProvider, provider.trim())
                .eq(CommerceProductChannelDomain::getStoreProductId, storeProductId.trim())
                .eq(CommerceProductChannelDomain::getStatus, STATUS_ACTIVE)
                .eq(CommerceProductChannelDomain::isDelFlag, false);
    }
}
