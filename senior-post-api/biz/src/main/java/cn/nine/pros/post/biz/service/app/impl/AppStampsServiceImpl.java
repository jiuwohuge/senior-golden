package cn.nine.pros.post.biz.service.app.impl;

import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.controller.app.AppPageHelper;
import cn.nine.pros.post.biz.model.domain.StampTransactionDomain;
import cn.nine.pros.post.biz.model.mapstruct.StampTransactionMapstruct;
import cn.nine.pros.post.biz.service.app.AppStampsService;
import cn.nine.pros.post.biz.service.base.StampTransactionService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.client.model.db.StampTransactionDTO;
import cn.nine.pros.post.client.model.db.UserDTO;
import cn.nine.pros.post.client.model.out.AppStampBalanceVO;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AppStampsServiceImpl implements AppStampsService {

    private final UserService userService;
    private final StampTransactionService stampTransactionService;
    private final StampTransactionMapstruct stampTransactionMapstruct;

    @Override
    public AppStampBalanceVO balance(long userId) {
        UserDTO u = userService.findById(userId);
        if (u == null) {
            return AppStampBalanceVO.builder()
                    .stampsBalance(0)
                    .isVip(false)
                    .vipExpireAt(null)
                    .build();
        }
        Integer bal = u.getStampsBalance() != null ? u.getStampsBalance() : 0;
        Boolean vip = Boolean.TRUE.equals(u.getIsVip());
        return AppStampBalanceVO.builder()
                .stampsBalance(bal)
                .isVip(vip)
                .vipExpireAt(parseVipExpire(u.getVipExpireAt()))
                .build();
    }

    @Override
    public PageData<StampTransactionDTO> ledgerPage(long userId, PageQuery rawPage) {
        PageQuery page = AppPageHelper.normalize(rawPage);
        LambdaQueryWrapper<StampTransactionDomain> qw = new LambdaQueryWrapper<StampTransactionDomain>()
                .eq(StampTransactionDomain::getUserId, userId)
                .eq(StampTransactionDomain::isDelFlag, false)
                .orderByDesc(StampTransactionDomain::getCreatedAt);
        Page<StampTransactionDomain> p = stampTransactionService.page(AppPageHelper.mpPage(page), qw);
        List<StampTransactionDTO> list = p.getRecords().stream()
                .map(stampTransactionMapstruct::toDTO)
                .collect(Collectors.toList());
        return AppPageHelper.pageData(page, p, list);
    }

    private static LocalDateTime parseVipExpire(Object raw) {
        if (raw == null) {
            return null;
        }
        if (raw instanceof LocalDateTime ldt) {
            return ldt;
        }
        if (raw instanceof Timestamp ts) {
            return ts.toLocalDateTime();
        }
        return null;
    }
}
