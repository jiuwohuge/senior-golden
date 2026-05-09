package cn.nine.pros.post.biz.service.base;

import java.time.LocalDateTime;

/**
 * 邮票余额 CAS 扣减（与 {@code bu_user.stamps_balance} 对齐）。
 */
public interface StampAccountService {

    /**
     * 乐观锁扣减：仅当当前余额等于 {@code expectedOldBalance} 时写入新余额。
     *
     * @return true 表示扣减成功；false 表示余额与预期不符或预期不足以支付（调用方可重试读库后再试或向用户报错）
     */
    boolean tryDecrementBalance(long userId, int expectedOldBalance, int delta,
                                LocalDateTime now, long updatedBy);

    /**
     * 增加邮票余额（用于赠送；delta 必须为正）。
     */
    void addBalance(long userId, int delta, LocalDateTime now, long updatedBy);
}
