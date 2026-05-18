package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.pros.post.biz.config.StampGrantProperties;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.mapper.StampDailyGrantMapper;
import cn.nine.pros.post.biz.mapper.StampTransactionMapper;
import cn.nine.pros.post.biz.model.domain.StampDailyGrantDomain;
import cn.nine.pros.post.biz.model.domain.StampTransactionDomain;
import cn.nine.pros.post.biz.service.base.StampAccountService;
import cn.nine.pros.post.biz.service.base.StampGrantService;
import cn.nine.pros.post.client.model.db.UserDTO;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class StampGrantServiceImpl implements StampGrantService {

    private final StampGrantProperties props;
    private final StampDailyGrantMapper stampDailyGrantMapper;
    private final StampAccountService stampAccountService;
    private final cn.nine.pros.post.biz.service.base.UserService userService;
    private final StampTransactionMapper stampTransactionMapper;
    private final AppMessages appMessages;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void afterLogin(long userId) {
        if (!props.isLoginEnabled() || props.getLoginDailyAmount() <= 0) {
            return;
        }
        LocalDate day = LocalDate.now(ZoneOffset.UTC);
        int amt = props.getLoginDailyAmount();
        StampDailyGrantDomain row = new StampDailyGrantDomain();
        row.setUserId(userId);
        row.setGrantDay(day);
        row.setGrantKind(StampDailyGrantDomain.KIND_LOGIN);
        row.setRefId(null);
        row.setAmount(amt);
        row.setCreatedAt(LocalDateTime.now());
        int inserted = stampDailyGrantMapper.insertLoginGrantIgnoreConflict(row);
        if (inserted <= 0) {
            log.debug("Daily login stamp grant skipped (already granted): userId={}", userId);
            return;
        }
        credit(userId, amt, appMessages.get("app.stamp.reason.dailyLoginCredit"), null);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void afterPostcardCreated(long userId, long postcardId) {
        if (!props.isPostcardEnabled() || props.getPostcardRewardPerPost() <= 0) {
            return;
        }
        LocalDate day = LocalDate.now(ZoneOffset.UTC);
        int reward = props.getPostcardRewardPerPost();
        if (existsPostcardGrant(userId, postcardId)) {
            return;
        }
        int cap = props.getPostcardDailyStampCap();
        if (cap > 0 && reward > cap) {
            log.debug("Postcard reward per post exceeds daily cap; skip userId={}", userId);
            return;
        }
        if (cap > 0) {
            int used = sumPostcardRewardsForDay(userId, day);
            if (used + reward > cap) {
                log.debug("Postcard stamp reward skipped (daily cap): userId={} used={} cap={}",
                        userId, used, cap);
                return;
            }
        }

        StampDailyGrantDomain row = new StampDailyGrantDomain();
        row.setUserId(userId);
        row.setGrantDay(day);
        row.setGrantKind(StampDailyGrantDomain.KIND_POSTCARD);
        row.setRefId(postcardId);
        row.setAmount(reward);
        row.setCreatedAt(LocalDateTime.now());
        int inserted = stampDailyGrantMapper.insertPostcardGrantIgnoreConflict(row);
        if (inserted <= 0) {
            log.debug("Postcard stamp grant skipped (duplicate postcard): userId={} postcardId={}",
                    userId, postcardId);
            return;
        }
        credit(userId, reward, appMessages.get("app.stamp.reason.postcardPublishCredit"), postcardId);
    }

    private boolean existsPostcardGrant(long userId, long postcardId) {
        return stampDailyGrantMapper.selectCount(new LambdaQueryWrapper<StampDailyGrantDomain>()
                .eq(StampDailyGrantDomain::getUserId, userId)
                .eq(StampDailyGrantDomain::getGrantKind, StampDailyGrantDomain.KIND_POSTCARD)
                .eq(StampDailyGrantDomain::getRefId, postcardId)) > 0;
    }

    private int sumPostcardRewardsForDay(long userId, LocalDate day) {
        List<StampDailyGrantDomain> rows = stampDailyGrantMapper.selectList(
                new LambdaQueryWrapper<StampDailyGrantDomain>()
                        .eq(StampDailyGrantDomain::getUserId, userId)
                        .eq(StampDailyGrantDomain::getGrantDay, day)
                        .eq(StampDailyGrantDomain::getGrantKind, StampDailyGrantDomain.KIND_POSTCARD));
        int sum = 0;
        for (StampDailyGrantDomain r : rows) {
            if (r.getAmount() != null) {
                sum += r.getAmount();
            }
        }
        return sum;
    }

    private void credit(long userId, int delta, String reason, Long refId) {
        UserDTO u = userService.findById(userId);
        if (u == null) {
            return;
        }
        int oldBal = u.getStampsBalance() != null ? u.getStampsBalance() : 0;
        LocalDateTime now = LocalDateTime.now();
        stampAccountService.addBalance(userId, delta, now, userId);
        int newBal = oldBal + delta;

        StampTransactionDomain tx = new StampTransactionDomain();
        tx.initAudit(userId);
        tx.setUserId(userId);
        tx.setChangeAmount(delta);
        tx.setBalanceAfter(newBal);
        tx.setReason(reason);
        tx.setRefId(refId);
        stampTransactionMapper.insert(tx);
    }
}
