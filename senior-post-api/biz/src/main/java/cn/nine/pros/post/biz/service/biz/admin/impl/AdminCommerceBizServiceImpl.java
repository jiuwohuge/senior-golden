package cn.nine.pros.post.biz.service.biz.admin.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.unchecked.BusinessException;
import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.controller.admin.AdminPageHelper;
import cn.nine.pros.post.biz.model.domain.CommerceProductDomain;
import cn.nine.pros.post.biz.model.domain.UserEntitlementDomain;
import cn.nine.pros.post.biz.service.base.CommerceProductService;
import cn.nine.pros.post.biz.service.base.UserEntitlementService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.biz.service.biz.admin.AdminCommerceBizService;
import cn.nine.pros.post.biz.service.biz.admin.support.AdminOperationRecorder;
import cn.nine.pros.post.client.model.db.UserDTO;
import cn.nine.pros.post.client.model.input.admin.AdminCommerceGrantInDto;
import cn.nine.pros.post.client.model.input.admin.AdminCommerceProductBatchStatusInDto;
import cn.nine.pros.post.client.model.input.admin.AdminCommerceProductQueryInDto;
import cn.nine.pros.post.client.model.input.admin.AdminCommerceProductSaveInDto;
import cn.nine.pros.post.client.model.out.CommerceEntitlementVO;
import cn.nine.pros.post.client.model.out.CommerceProductVO;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class AdminCommerceBizServiceImpl implements AdminCommerceBizService {

    private static final String SOURCE_ADMIN = "admin_grant";

    private final CommerceProductService commerceProductService;
    private final UserEntitlementService userEntitlementService;
    private final UserService userService;
    private final AdminOperationRecorder adminOperationRecorder;

    @Override
    public PageData<CommerceProductVO> pagingProducts(AdminCommerceProductQueryInDto body) {
        PageQuery pageQuery = AdminPageHelper.normalize(body.getPage());
        Page<CommerceProductDomain> page = commerceProductService.pageForAdmin(
                pageQuery, body.getProductType(), body.getStatus());
        List<CommerceProductVO> records = page.getRecords().stream()
                .map(p -> CommerceProductVO.builder()
                        .id(p.getId())
                        .productCode(p.getProductCode())
                        .productType(p.getProductType())
                        .titleKey(p.getTitleKey())
                        .priceCents(p.getPriceCents())
                        .metadataJson(p.getMetadataJson())
                        .sortOrder(p.getSortOrder())
                        .status(p.getStatus())
                        .build())
                .collect(Collectors.toList());
        return AdminPageHelper.pageData(pageQuery, page, records);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public CommerceProductVO saveProduct(AdminCommerceProductSaveInDto body) {
        CommerceProductDomain row = new CommerceProductDomain();
        row.setId(body.getId());
        row.setProductCode(body.getProductCode());
        row.setProductType(body.getProductType());
        row.setTitleKey(body.getTitleKey());
        row.setPriceCents(body.getPriceCents());
        row.setMetadataJson(body.getMetadataJson());
        row.setSortOrder(body.getSortOrder());
        row.setStatus(body.getStatus());
        CommerceProductDomain saved = commerceProductService.upsertFromAdmin(row, MyRequestContextHolder.userId());
        adminOperationRecorder.record("commerce.product_save", "commerce_product", saved.getId(),
                "code=" + saved.getProductCode());
        log.info("commerce product saved, productId={}, code={}", saved.getId(), saved.getProductCode());
        return CommerceProductVO.builder()
                .id(saved.getId())
                .productCode(saved.getProductCode())
                .productType(saved.getProductType())
                .titleKey(saved.getTitleKey())
                .priceCents(saved.getPriceCents())
                .metadataJson(saved.getMetadataJson())
                .sortOrder(saved.getSortOrder())
                .status(saved.getStatus())
                .build();
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
}
