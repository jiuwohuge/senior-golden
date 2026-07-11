package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.pros.post.biz.mapper.CommerceProductMapper;
import cn.nine.pros.post.biz.model.domain.CommerceProductDomain;
import cn.nine.pros.post.biz.service.base.CommerceProductService;
import cn.nine.pros.post.biz.support.PageQueryNormalize;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;

@Service
public class CommerceProductServiceImpl extends ServiceImpl<CommerceProductMapper, CommerceProductDomain>
        implements CommerceProductService {

    private static final int STATUS_ACTIVE = 1;

    @Override
    public List<CommerceProductDomain> listActiveByType(String type) {
        LambdaQueryWrapper<CommerceProductDomain> qw = activeQueryWrapper();
        if (StringUtils.hasText(type)) {
            qw.eq(CommerceProductDomain::getProductType, type.trim());
        }
        qw.orderByAsc(CommerceProductDomain::getSortOrder)
                .orderByAsc(CommerceProductDomain::getId);
        return list(qw);
    }

    @Override
    public CommerceProductDomain findByCode(String code) {
        if (!StringUtils.hasText(code)) {
            return null;
        }
        return getOne(new LambdaQueryWrapper<CommerceProductDomain>()
                .eq(CommerceProductDomain::getProductCode, code.trim())
                .eq(CommerceProductDomain::getStatus, STATUS_ACTIVE)
                .eq(CommerceProductDomain::isDelFlag, false)
                .last("LIMIT 1"));
    }

    @Override
    public List<CommerceProductDomain> listAllActive() {
        return list(activeQueryWrapper()
                .orderByAsc(CommerceProductDomain::getProductType)
                .orderByAsc(CommerceProductDomain::getSortOrder)
                .orderByAsc(CommerceProductDomain::getId));
    }

    private LambdaQueryWrapper<CommerceProductDomain> activeQueryWrapper() {
        return new LambdaQueryWrapper<CommerceProductDomain>()
                .eq(CommerceProductDomain::getStatus, STATUS_ACTIVE)
                .eq(CommerceProductDomain::isDelFlag, false);
    }

    @Override
    public Page<CommerceProductDomain> pageForAdmin(
            cn.nine.commons.data.page.PageQuery pageQuery, String productType, Integer status) {
        LambdaQueryWrapper<CommerceProductDomain> qw = new LambdaQueryWrapper<CommerceProductDomain>()
                .eq(CommerceProductDomain::isDelFlag, false)
                .orderByAsc(CommerceProductDomain::getProductType)
                .orderByAsc(CommerceProductDomain::getSortOrder)
                .orderByAsc(CommerceProductDomain::getId);
        if (StringUtils.hasText(productType)) {
            qw.eq(CommerceProductDomain::getProductType, productType.trim());
        }
        if (status != null) {
            qw.eq(CommerceProductDomain::getStatus, status);
        }
        return page(PageQueryNormalize.mpPage(pageQuery, PageQueryNormalize.ADMIN_MAX_SIZE), qw);
    }

    @Override
    public CommerceProductDomain upsertFromAdmin(CommerceProductDomain row, Long actorId) {
        if (row == null) {
            return null;
        }
        Long auditUserId = actorId != null ? actorId : 0L;
        LocalDateTime now = LocalDateTime.now();
        if (row.getId() == null) {
            row.initAudit(auditUserId);
            if (row.getStatus() == null) {
                row.setStatus(STATUS_ACTIVE);
            }
            if (row.getSortOrder() == null) {
                row.setSortOrder(0);
            }
            if (row.getPriceCents() == null) {
                row.setPriceCents(0);
            }
            save(row);
            return row;
        }
        row.setUpdatedAt(now);
        row.setUpdatedBy(auditUserId);
        updateById(row);
        return row;
    }

    @Override
    public void batchUpdateStatus(Collection<Long> ids, int status, Long actorId) {
        if (ids == null || ids.isEmpty()) {
            return;
        }
        LocalDateTime now = LocalDateTime.now();
        update(new LambdaUpdateWrapper<CommerceProductDomain>()
                .in(CommerceProductDomain::getId, ids)
                .eq(CommerceProductDomain::isDelFlag, false)
                .set(CommerceProductDomain::getStatus, status)
                .set(CommerceProductDomain::getUpdatedBy, actorId)
                .set(CommerceProductDomain::getUpdatedAt, now));
    }
}
