package cn.nine.pros.post.biz.service.biz.admin;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.unchecked.BusinessException;
import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.controller.admin.AdminPageHelper;
import cn.nine.pros.post.biz.model.domain.LetterDomain;
import cn.nine.pros.post.biz.model.mapstruct.LetterMapstruct;
import cn.nine.pros.post.biz.service.base.LetterService;
import cn.nine.pros.post.client.common.enums.LetterBizStatus;
import cn.nine.pros.post.client.model.db.LetterDTO;
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

    /**
     * 按审核状态/模式分页。
     */
    public PageData<LetterDTO> paging(LetterAuditQueryInDto body) {
        PageQuery pageQuery = AdminPageHelper.normalize(body.getPage());
        Page<LetterDomain> p = letterService.pageForAdminAudit(
                pageQuery, body.getAuditStatus(), body.getMode());
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
        log.info("letter audit rejected, letterId={}, adminId={}", id, MyRequestContextHolder.userId());
    }
}
