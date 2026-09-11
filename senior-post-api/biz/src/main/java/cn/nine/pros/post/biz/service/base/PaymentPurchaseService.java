package cn.nine.pros.post.biz.service.base;

import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.model.domain.PaymentPurchaseDomain;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;

import java.time.LocalDateTime;

/**
 * 支付购买主单 Base Service。
 */
public interface PaymentPurchaseService extends IService<PaymentPurchaseDomain> {

    PaymentPurchaseDomain findByTokenHash(String purchaseTokenHash);

    PaymentPurchaseDomain findByPurchaseNo(String purchaseNo);

    /** 未删除购买行。 */
    PaymentPurchaseDomain findByIdNotDeleted(Long id);

    /**
     * 管理端购买分页（不含 token 明文；Biz 层再映射 VO）。
     */
    Page<PaymentPurchaseDomain> pageForAdmin(
            PageQuery pageQuery,
            Long userId,
            String purchaseNo,
            Long productId,
            String status,
            LocalDateTime purchasedAtFrom,
            LocalDateTime purchasedAtTo);

    /**
     * 按 token hash 幂等写入/刷新购买行。
     *
     * @return 持久化后的行
     */
    PaymentPurchaseDomain upsertByTokenHash(PaymentPurchaseDomain row, long actorId);
}
