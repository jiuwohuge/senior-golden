package cn.nine.pros.post.biz.service.biz.admin.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.unchecked.BusinessException;
import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.controller.admin.AdminPageHelper;
import cn.nine.pros.post.biz.model.domain.CommerceProductChannelDomain;
import cn.nine.pros.post.biz.model.domain.CommerceProductDomain;
import cn.nine.pros.post.biz.model.domain.UserEntitlementDomain;
import cn.nine.pros.post.biz.service.base.CommerceProductChannelService;
import cn.nine.pros.post.biz.service.base.CommerceProductService;
import cn.nine.pros.post.biz.service.base.UserEntitlementService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.biz.service.biz.admin.AdminCommerceBizService;
import cn.nine.pros.post.biz.service.biz.admin.support.AdminOperationRecorder;
import cn.nine.pros.post.client.model.db.UserDTO;
import cn.nine.pros.post.client.model.input.admin.AdminCommerceGrantInDto;
import cn.nine.pros.post.client.model.input.admin.AdminCommerceProductBatchStatusInDto;
import cn.nine.pros.post.client.model.input.admin.AdminCommerceProductChannelInDto;
import cn.nine.pros.post.client.model.input.admin.AdminCommerceProductQueryInDto;
import cn.nine.pros.post.client.model.input.admin.AdminCommerceProductSaveInDto;
import cn.nine.pros.post.client.model.out.CommerceEntitlementVO;
import cn.nine.pros.post.client.model.out.CommerceProductChannelVO;
import cn.nine.pros.post.client.model.out.CommerceProductVO;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

/**
 * 管理端商业商品：分页/保存（含渠道）/批量状态/手动发权。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AdminCommerceBizServiceImpl implements AdminCommerceBizService {

    private static final String SOURCE_ADMIN = "admin_grant";

    private final CommerceProductService commerceProductService;
    private final CommerceProductChannelService commerceProductChannelService;
    private final UserEntitlementService userEntitlementService;
    private final UserService userService;
    private final AdminOperationRecorder adminOperationRecorder;

    @Override
    public PageData<CommerceProductVO> pagingProducts(AdminCommerceProductQueryInDto body) {
        PageQuery pageQuery = AdminPageHelper.normalize(body.getPage());
        Page<CommerceProductDomain> page = commerceProductService.pageForAdmin(
                pageQuery, body.getProductType(), body.getStatus());
        Map<Long, List<CommerceProductChannelVO>> channelMap = loadChannelsByProductIds(
                page.getRecords().stream().map(CommerceProductDomain::getId).filter(Objects::nonNull).toList());
        List<CommerceProductVO> records = page.getRecords().stream()
                .map(p -> toProductVo(p, channelMap.getOrDefault(p.getId(), List.of())))
                .collect(Collectors.toList());
        return AdminPageHelper.pageData(pageQuery, page, records);
    }

    /**
     * 保存商品并 upsert 渠道；channels 为 null 时不改渠道，空列表则清空渠道。
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public CommerceProductVO saveProduct(AdminCommerceProductSaveInDto body) {
        CommerceProductDomain row = new CommerceProductDomain();
        row.setId(body.getId());
        row.setProductCode(body.getProductCode());
        row.setProductType(body.getProductType());
        row.setEntitlementCode(body.getEntitlementCode());
        row.setTitleKey(body.getTitleKey());
        row.setPriceCents(body.getPriceCents());
        row.setMetadataJson(body.getMetadataJson());
        row.setSortOrder(body.getSortOrder());
        row.setStatus(body.getStatus());
        Long actorId = MyRequestContextHolder.userId();
        CommerceProductDomain saved = commerceProductService.upsertFromAdmin(row, actorId);

        List<CommerceProductChannelVO> channels;
        if (body.getChannels() == null) {
            channels = toChannelVos(commerceProductChannelService.listByProductId(saved.getId()));
        } else {
            List<CommerceProductChannelDomain> channelDomains = body.getChannels().stream()
                    .map(this::toChannelDomain)
                    .collect(Collectors.toList());
            commerceProductChannelService.upsertChannelsForProduct(saved.getId(), channelDomains, actorId);
            channels = toChannelVos(commerceProductChannelService.listByProductId(saved.getId()));
        }

        adminOperationRecorder.record("commerce.product_save", "commerce_product", saved.getId(),
                "code=" + saved.getProductCode() + ",channels=" + channels.size());
        log.info("commerce product saved, productId={}, code={}, channels={}",
                saved.getId(), saved.getProductCode(), channels.size());
        return toProductVo(saved, channels);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void batchProductStatus(AdminCommerceProductBatchStatusInDto body) {
        commerceProductService.batchUpdateStatus(body.getIds(), body.getStatus(), MyRequestContextHolder.userId());
        for (Long id : body.getIds()) {
            adminOperationRecorder.record("commerce.product_batch_status", "commerce_product", id,
                    "status=" + body.getStatus());
        }
        log.info("commerce product batch status, count={}, status={}", body.getIds().size(), body.getStatus());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public CommerceEntitlementVO grant(AdminCommerceGrantInDto body) {
        UserDTO user = userService.findById(body.getUserId());
        if (user == null) {
            throw new BusinessException("user not found");
        }
        CommerceProductDomain product = commerceProductService.getById(body.getProductId());
        if (product == null || product.isDelFlag()) {
            throw new BusinessException("product not found");
        }
        UserEntitlementDomain row = userEntitlementService.grant(
                body.getUserId(), body.getProductId(), SOURCE_ADMIN, MyRequestContextHolder.userId());
        log.info("admin grant entitlement, userId={}, productId={}", body.getUserId(), body.getProductId());
        return CommerceEntitlementVO.builder()
                .entitlementId(row.getId())
                .productId(row.getProductId())
                .productCode(product.getProductCode())
                .productType(product.getProductType())
                .titleKey(product.getTitleKey())
                .source(row.getSource())
                .expiresAt(row.getExpiresAt())
                .grantedAt(row.getCreatedAt())
                .build();
    }

    private Map<Long, List<CommerceProductChannelVO>> loadChannelsByProductIds(List<Long> productIds) {
        List<CommerceProductChannelDomain> rows = commerceProductChannelService.listByProductIds(productIds);
        Map<Long, List<CommerceProductChannelVO>> map = new HashMap<>();
        for (CommerceProductChannelDomain row : rows) {
            map.computeIfAbsent(row.getProductId(), k -> new ArrayList<>()).add(toChannelVo(row));
        }
        return map;
    }

    private static CommerceProductVO toProductVo(CommerceProductDomain p, List<CommerceProductChannelVO> channels) {
        return CommerceProductVO.builder()
                .id(p.getId())
                .productCode(p.getProductCode())
                .productType(p.getProductType())
                .entitlementCode(p.getEntitlementCode())
                .titleKey(p.getTitleKey())
                .priceCents(p.getPriceCents())
                .metadataJson(p.getMetadataJson())
                .sortOrder(p.getSortOrder())
                .status(p.getStatus())
                .channels(channels == null ? Collections.emptyList() : channels)
                .build();
    }

    private List<CommerceProductChannelVO> toChannelVos(List<CommerceProductChannelDomain> rows) {
        if (rows == null || rows.isEmpty()) {
            return List.of();
        }
        return rows.stream().map(this::toChannelVo).collect(Collectors.toList());
    }

    private CommerceProductChannelVO toChannelVo(CommerceProductChannelDomain c) {
        return CommerceProductChannelVO.builder()
                .id(c.getId())
                .productId(c.getProductId())
                .provider(c.getProvider())
                .storeProductId(c.getStoreProductId())
                .basePlanId(c.getBasePlanId())
                .offerId(c.getOfferId())
                .appIdOrPackageName(c.getAppIdOrPackageName())
                .environment(c.getEnvironment())
                .status(c.getStatus())
                .providerConfigJson(c.getProviderConfigJson())
                .build();
    }

    private CommerceProductChannelDomain toChannelDomain(AdminCommerceProductChannelInDto in) {
        CommerceProductChannelDomain row = new CommerceProductChannelDomain();
        row.setId(in.getId());
        row.setProvider(in.getProvider());
        row.setStoreProductId(in.getStoreProductId());
        row.setBasePlanId(in.getBasePlanId());
        row.setOfferId(in.getOfferId());
        row.setAppIdOrPackageName(in.getAppIdOrPackageName());
        row.setEnvironment(in.getEnvironment());
        row.setStatus(in.getStatus());
        row.setProviderConfigJson(in.getProviderConfigJson());
        return row;
    }
}
