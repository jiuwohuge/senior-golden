package cn.nine.pros.post.biz.service.biz.impl;

import cn.nine.commons.basic.exception.unchecked.BusinessException;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.model.domain.CommerceProductDomain;
import cn.nine.pros.post.biz.model.domain.UserEntitlementDomain;
import cn.nine.pros.post.biz.service.base.ActionService;
import cn.nine.pros.post.biz.service.base.CommerceProductService;
import cn.nine.pros.post.biz.service.base.UserEntitlementService;
import cn.nine.pros.post.biz.service.biz.AppCommerceBizService;
import cn.nine.pros.post.client.common.constant.BehaviorActionTypes;
import cn.nine.pros.post.client.model.input.app.CommerceMockPurchaseInDto;
import cn.nine.pros.post.client.model.out.CommerceEntitlementVO;
import cn.nine.pros.post.client.model.out.CommerceProductVO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.HashSet;
import java.util.List;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class AppCommerceBizServiceImpl implements AppCommerceBizService {

    private static final int STATUS_ACTIVE = 1;
    private static final String SOURCE_MOCK = "mock_purchase";

    private final CommerceProductService commerceProductService;
    private final UserEntitlementService userEntitlementService;
    private final ActionService actionService;
    private final AppMessages appMessages;

    @Override
    public List<CommerceProductVO> catalog(long userId) {
        Set<Long> ownedIds = ownedProductIds(userId);
        return commerceProductService.listAllActive().stream()
                .map(p -> toProductVo(p, ownedIds.contains(p.getId()) || isFreeProduct(p)))
                .collect(Collectors.toList());
    }

    @Override
    public List<CommerceEntitlementVO> entitlements(long userId) {
        return userEntitlementService.listActiveForUser(userId).stream()
                .map(this::toEntitlementVo)
                .filter(Objects::nonNull)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public CommerceEntitlementVO mockPurchase(long userId, CommerceMockPurchaseInDto body) {
        if (body == null || body.getProductId() == null) {
            throw new BusinessException(appMessages.get("app.error.commerce.productNotFound"));
        }
        CommerceProductDomain product = commerceProductService.getById(body.getProductId());
        if (product == null || product.isDelFlag()) {
            throw new BusinessException(appMessages.get("app.error.commerce.productNotFound"));
        }
        if (!Objects.equals(product.getStatus(), STATUS_ACTIVE)) {
            throw new BusinessException(appMessages.get("app.error.commerce.productInactive"));
        }
        UserEntitlementDomain row = userEntitlementService.grant(userId, product.getId(), SOURCE_MOCK, userId);
        actionService.recordEvent(
                userId,
                BehaviorActionTypes.MOCK_PURCHASE,
                BehaviorActionTypes.TARGET_USER,
                product.getId(),
                null);
        log.info("mock purchase granted, userId={}, productId={}", userId, product.getId());
        return toEntitlementVo(row);
    }

    @Override
    public void assertLetterContentEntitlements(long userId, String skinId, String fontId, String templateId) {
        assertProductEntitlement(userId, "skin", skinId);
        assertProductEntitlement(userId, "font", fontId);
        assertProductEntitlement(userId, "template", templateId);
    }

    private void assertProductEntitlement(long userId, String type, String id) {
        if (!StringUtils.hasText(id) || "default".equalsIgnoreCase(id.trim())) {
            return;
        }
        String code = type + "." + id.trim();
        CommerceProductDomain product = commerceProductService.findByCode(code);
        if (isFreeProduct(product)) {
            return;
        }
        if (userEntitlementService.hasEntitlementByCode(userId, code)) {
            return;
        }
        throw new BusinessException(appMessages.get("app.error.commerce.entitlementRequired"));
    }

    private static boolean isFreeProduct(CommerceProductDomain product) {
        return product != null
                && !product.isDelFlag()
                && (product.getPriceCents() == null || product.getPriceCents() <= 0);
    }

    private Set<Long> ownedProductIds(long userId) {
        Set<Long> ids = new HashSet<>();
        for (UserEntitlementDomain row : userEntitlementService.listActiveForUser(userId)) {
            if (row.getProductId() != null) {
                ids.add(row.getProductId());
            }
        }
        return ids;
    }

    private CommerceProductVO toProductVo(CommerceProductDomain p, boolean owned) {
        return CommerceProductVO.builder()
                .id(p.getId())
                .productCode(p.getProductCode())
                .productType(p.getProductType())
                .titleKey(p.getTitleKey())
                .priceCents(p.getPriceCents())
                .metadataJson(p.getMetadataJson())
                .sortOrder(p.getSortOrder())
                .status(p.getStatus())
                .owned(owned)
                .build();
    }

    private CommerceEntitlementVO toEntitlementVo(UserEntitlementDomain row) {
        if (row == null || row.getProductId() == null) {
            return null;
        }
        CommerceProductDomain product = commerceProductService.getById(row.getProductId());
        return CommerceEntitlementVO.builder()
                .entitlementId(row.getId())
                .productId(row.getProductId())
                .productCode(product != null ? product.getProductCode() : null)
                .productType(product != null ? product.getProductType() : null)
                .titleKey(product != null ? product.getTitleKey() : null)
                .source(row.getSource())
                .expiresAt(row.getExpiresAt())
                .grantedAt(row.getCreatedAt())
                .build();
    }
}
