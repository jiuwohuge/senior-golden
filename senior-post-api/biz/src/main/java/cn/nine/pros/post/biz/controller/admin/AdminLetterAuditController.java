package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.biz.service.biz.admin.AdminLetterAuditBizService;
import cn.nine.pros.post.client.api.admin.AdminLetterAuditApi;
import cn.nine.pros.post.client.model.db.LetterDTO;
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
}
