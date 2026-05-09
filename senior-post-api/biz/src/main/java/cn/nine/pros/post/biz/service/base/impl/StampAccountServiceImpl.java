package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.pros.post.biz.model.domain.UserDomain;
import cn.nine.pros.post.biz.service.base.StampAccountService;
import cn.nine.pros.post.biz.service.base.UserService;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class StampAccountServiceImpl implements StampAccountService {

    private final UserService userService;

    @Override
    public boolean tryDecrementBalance(long userId, int expectedOldBalance, int delta,
                                       LocalDateTime now, long updatedBy) {
        if (delta <= 0) {
            throw new IllegalArgumentException("delta must be positive");
        }
        if (expectedOldBalance < delta) {
            return false;
        }
        int newBal = expectedOldBalance - delta;
        return userService.update(new LambdaUpdateWrapper<UserDomain>()
                .eq(UserDomain::getId, userId)
                .eq(UserDomain::isDelFlag, false)
                .eq(UserDomain::getStampsBalance, expectedOldBalance)
                .set(UserDomain::getStampsBalance, newBal)
                .set(UserDomain::getUpdatedAt, now)
                .set(UserDomain::getUpdatedBy, updatedBy));
    }

    @Override
    public void addBalance(long userId, int delta, LocalDateTime now, long updatedBy) {
        if (delta <= 0) {
            throw new IllegalArgumentException("delta must be positive");
        }
        userService.update(new LambdaUpdateWrapper<UserDomain>()
                .eq(UserDomain::getId, userId)
                .eq(UserDomain::isDelFlag, false)
                .setSql("stamps_balance = stamps_balance + " + delta)
                .set(UserDomain::getUpdatedAt, now)
                .set(UserDomain::getUpdatedBy, updatedBy));
    }
}
