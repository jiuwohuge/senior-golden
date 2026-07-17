package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.biz.service.biz.admin.AdminLetterAuditBizService;
import cn.nine.pros.post.client.api.admin.AdminLetterAuditApi;
import cn.nine.pros.post.client.model.db.LetterDTO;
import cn.nine.pros.post.client.model.input.admin.AdminIdListInDto;
import cn.nine.pros.post.client.model.input.admin.LetterAuditQueryInDto;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class AdminLetterAuditController implements AdminLetterAuditApi {

    private final AdminLetterAuditBizService adminLetterAuditBizService;

    @Override
    public PageData<LetterDTO> paging(LetterAuditQueryInDto body) {
        return adminLetterAuditBizService.paging(body);
    }

    @Override
    public void approve(Long id) {
        adminLetterAuditBizService.approve(id);
    }

    @Override
    public void reject(Long id) {
        adminLetterAuditBizService.reject(id);
    }

    @Override
    public void batchApprove(AdminIdListInDto body) {
        adminLetterAuditBizService.batchApprove(body);
    }

    @Override
    public void batchReject(AdminIdListInDto body) {
        adminLetterAuditBizService.batchReject(body);
    }

    @Override
    public void forceDeliver(Long id) {
        adminLetterAuditBizService.forceDeliver(id);
    }
}
