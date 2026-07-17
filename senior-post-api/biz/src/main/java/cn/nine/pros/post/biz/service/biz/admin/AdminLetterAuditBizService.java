package cn.nine.pros.post.biz.service.biz.admin;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.unchecked.BusinessException;
import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.controller.admin.AdminPageHelper;
import cn.nine.pros.post.biz.model.domain.LetterDomain;
import cn.nine.pros.post.biz.model.mapstruct.LetterMapstruct;
import cn.nine.pros.post.biz.service.base.LetterService;
import cn.nine.pros.post.biz.service.biz.admin.support.AdminOperationRecorder;
import cn.nine.pros.post.biz.service.push.PushNotificationService;
import cn.nine.pros.post.client.common.enums.LetterBizStatus;
import cn.nine.pros.post.client.model.db.LetterDTO;
import cn.nine.pros.post.client.model.input.admin.AdminIdListInDto;
import cn.nine.pros.post.client.model.input.admin.LetterAuditQueryInDto;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

/**
 * 管理端信件内容审核：列表、通过、拒绝（拒绝中止在途投递）。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AdminLetterAuditBizService {

    private final LetterService letterService;
    private final LetterMapstruct letterMapstruct;
    private final PushNotificationService pushNotificationService;
    private final AdminOperationRecorder adminOperationRecorder;

    /**
     * 按审核状态/业务状态/收发用户/关键词分页。
     */
    public PageData<LetterDTO> paging(LetterAuditQueryInDto body) {
        PageQuery pageQuery = AdminPageHelper.normalize(body.getPage());
        Page<LetterDomain> p = letterService.pageForAdminAudit(
                pageQuery,
                body.getAuditStatus(), body.getMode(), body.getStatus(),
                body.getFromUserId(), body.getToUserId(), body.getKeyword(),
                body.getCreatedFrom(), body.getCreatedTo());
        List<LetterDTO> list = p.getRecords().stream().map(letterMapstruct::toDTO).collect(Collectors.toList());
        return AdminPageHelper.pageData(pageQuery, p, list);
    }

    /**
     * 审核通过。
     */
    @Transactional(rollbackFor = Exception.class)
    public void approve(Long id) {
        if (id == null) {
            throw new BusinessException("letter id required");
        }
        LocalDateTime now = LocalDateTime.now();
        if (!letterService.approveAudit(id, now, MyRequestContextHolder.userId())) {
            throw new BusinessException("letter not found or already rejected");
        }
        adminOperationRecorder.record("letter.approve", "letter", id, null);
        log.info("letter audit approved, letterId={}, adminId={}", id, MyRequestContextHolder.userId());
    }

    /**
     * 审核拒绝；若在途则中止投递。拒绝信不计入当日额度。
     */
    @Transactional(rollbackFor = Exception.class)
    public void reject(Long id) {
        if (id == null) {
            throw new BusinessException("letter id required");
        }
        LetterDomain row = letterService.getById(id);
        if (row == null || row.isDelFlag()) {
            throw new BusinessException("letter not found");
        }
        LocalDateTime now = LocalDateTime.now();
        letterService.rejectAudit(id, now, MyRequestContextHolder.userId());
        if (Objects.equals(row.getStatus(), LetterBizStatus.DELIVERING.getCode())
                || Objects.equals(row.getStatus(), LetterBizStatus.MATCHED.getCode())) {
            letterService.abortDeliveryRejected(id, now);
        }
        adminOperationRecorder.record("letter.reject", "letter", id, null);
        log.info("letter audit rejected, letterId={}, adminId={}", id, MyRequestContextHolder.userId());
        if (row.getFromUserId() != null) {
            pushNotificationService.notifyAuditRejected(row.getFromUserId(), id);
        }
    }

    /**
     * 批量审核通过。
     */
    @Transactional(rollbackFor = Exception.class)
    public void batchApprove(AdminIdListInDto body) {
        for (Long id : body.getIds()) {
            approve(id);
        }
        log.info("letter batch approve, count={}", body.getIds().size());
    }

    /**
     * 批量审核拒绝。
     */
    @Transactional(rollbackFor = Exception.class)
    public void batchReject(AdminIdListInDto body) {
        for (Long id : body.getIds()) {
            reject(id);
        }
        log.info("letter batch reject, count={}", body.getIds().size());
    }

    /**
     * 调试：将 MATCHED/DELIVERING 且已有收件人的信件立即置为已送达（跳过预计到达时间）。
     */
    @Transactional(rollbackFor = Exception.class)
    public void forceDeliver(Long id) {
        if (id == null) {
            throw new BusinessException("letter id required");
        }
        LetterDomain row = letterService.getById(id);
        if (row == null || row.isDelFlag()) {
            throw new BusinessException("letter not found");
        }
        if (row.getToUserId() == null) {
            throw new BusinessException("尚未匹配收件人，无法立即送达");
        }
        int status = row.getStatus() instanceof Number n
                ? n.intValue()
                : Integer.parseInt(String.valueOf(row.getStatus()));
        if (status == LetterBizStatus.DELIVERED.getCode()) {
            throw new BusinessException("信件已送达");
        }
        if (status != LetterBizStatus.MATCHED.getCode()
                && status != LetterBizStatus.DELIVERING.getCode()) {
            throw new BusinessException("仅「已匹配」或「运输中」的信件可立即送达");
        }
        Long adminId = MyRequestContextHolder.userId();
        LocalDateTime now = LocalDateTime.now();
        if (!letterService.forceAdminDeliver(id, now, adminId)) {
            throw new BusinessException("信件状态已变更，请刷新后重试");
        }
        adminOperationRecorder.record("letter.force_deliver", "letter", id, null);
        log.info("letter force-delivered (admin debug), letterId={}, adminId={}, toUserId={}",
                id, adminId, row.getToUserId());
        pushNotificationService.notifyLetterDelivered(row.getToUserId(), id);
    }
}
