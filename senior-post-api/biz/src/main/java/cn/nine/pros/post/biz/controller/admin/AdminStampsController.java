package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.model.domain.StampTransactionDomain;
import cn.nine.pros.post.biz.model.mapstruct.StampTransactionMapstruct;
import cn.nine.pros.post.biz.service.base.StampTransactionService;
import cn.nine.pros.post.client.api.admin.AdminStampsApi;
import cn.nine.pros.post.client.model.db.StampTransactionDTO;
import cn.nine.pros.post.client.model.input.admin.AdminStampLedgerPageInDto;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.apache.commons.lang3.StringUtils;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequiredArgsConstructor
public class AdminStampsController implements AdminStampsApi {

    private final StampTransactionService stampTransactionService;
    private final StampTransactionMapstruct stampTransactionMapstruct;

    @Override
    public PageData<StampTransactionDTO> ledgerPaging(AdminStampLedgerPageInDto body) {
        PageQuery pageQuery = AdminPageHelper.normalize(body.getPage());
        LambdaQueryWrapper<StampTransactionDomain> qw = new LambdaQueryWrapper<StampTransactionDomain>()
                .eq(StampTransactionDomain::isDelFlag, false)
                .orderByDesc(StampTransactionDomain::getCreatedAt);
        if (body.getUserId() != null) {
            qw.eq(StampTransactionDomain::getUserId, body.getUserId());
        }
        if (StringUtils.isNotBlank(body.getReasonKeyword())) {
            qw.like(StampTransactionDomain::getReason, body.getReasonKeyword().trim());
        }
        Page<StampTransactionDomain> p = stampTransactionService.page(AdminPageHelper.mpPage(pageQuery), qw);
        List<StampTransactionDTO> list = p.getRecords().stream()
                .map(stampTransactionMapstruct::toDTO)
                .collect(Collectors.toList());
        return AdminPageHelper.pageData(pageQuery, p, list);
    }
}
