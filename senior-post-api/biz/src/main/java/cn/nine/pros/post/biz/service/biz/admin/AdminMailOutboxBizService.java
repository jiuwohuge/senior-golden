package cn.nine.pros.post.biz.service.biz.admin;

import cn.nine.commons.basic.exception.unchecked.BusinessException;
import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.controller.admin.AdminPageHelper;
import cn.nine.pros.post.biz.model.domain.MailOutboxDomain;
import cn.nine.pros.post.biz.service.base.MailOutboxService;
import cn.nine.pros.post.biz.service.biz.admin.support.AdminOperationRecorder;
import cn.nine.pros.post.client.model.input.admin.MailOutboxQueryInDto;
import cn.nine.pros.post.client.model.out.MailOutboxVO;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 管理端系统邮件出站：分页、详情、失败重试。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AdminMailOutboxBizService {

    private final MailOutboxService mailOutboxService;
    private final AdminOperationRecorder adminOperationRecorder;

    /**
     * 按收件邮箱/类型/状态/时间/关键词分页。
     */
    public PageData<MailOutboxVO> paging(MailOutboxQueryInDto body) {
        PageQuery pageQuery = AdminPageHelper.normalize(body.getPage());
        Page<MailOutboxDomain> p = mailOutboxService.pageForAdmin(
                pageQuery,
                body.getToEmail(), body.getMailType(), body.getStatus(),
                body.getCreatedFrom(), body.getCreatedTo(), body.getKeyword());
        List<MailOutboxVO> list = p.getRecords().stream().map(this::toVo).collect(Collectors.toList());
        return AdminPageHelper.pageData(pageQuery, p, list);
    }

    /**
     * 出站邮件详情。
     */
    public MailOutboxVO detail(Long id) {
        MailOutboxDomain row = mailOutboxService.findById(id);
        if (row == null) {
            throw new BusinessException("mail outbox not found");
        }
        return toVo(row);
    }

    /**
     * 失败重试：重置为 pending 并立即进入调度窗口。
     */
    @Transactional(rollbackFor = Exception.class)
    public void retry(Long id) {
        if (id == null) {
            throw new BusinessException("mail outbox id required");
        }
        MailOutboxDomain row = mailOutboxService.findById(id);
        if (row == null) {
            throw new BusinessException("mail outbox not found");
        }
        if (!mailOutboxService.retryFailed(id)) {
            throw new BusinessException("mail outbox retry failed");
        }
        adminOperationRecorder.record("mail_outbox.retry", "mail_outbox", id, "status=" + row.getStatus());
        log.info("mail outbox retry, id={}, previousStatus={}", id, row.getStatus());
    }

    private MailOutboxVO toVo(MailOutboxDomain d) {
        return MailOutboxVO.builder()
                .id(d.getId())
                .mailType(d.getMailType())
                .toEmail(d.getToEmail())
                .payloadJson(d.getPayloadJson())
                .localeTag(d.getLocaleTag())
                .status(d.getStatus())
                .attempts(d.getAttempts())
                .nextRetryAt(d.getNextRetryAt())
                .lastError(d.getLastError())
                .createdAt(d.getCreatedAt())
                .updatedAt(d.getUpdatedAt())
                .build();
    }
}
