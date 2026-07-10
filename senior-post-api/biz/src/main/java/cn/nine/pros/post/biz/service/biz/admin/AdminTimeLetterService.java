package cn.nine.pros.post.biz.service.biz.admin;

import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.controller.admin.AdminPageHelper;
import cn.nine.pros.post.biz.model.domain.TimeLetterDomain;
import cn.nine.pros.post.biz.service.base.TimeLetterService;
import cn.nine.pros.post.client.model.db.TimeLetterDTO;
import cn.nine.pros.post.client.model.input.admin.TimeLetterQueryInDto;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 管理端时光信：分页查询、详情与下架。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AdminTimeLetterService {

    private final TimeLetterService timeLetterService;

    /**
     * 按发/收件人与状态分页查询时光信。
     */
    public PageData<TimeLetterDTO> paging(TimeLetterQueryInDto body) {
        PageQuery pageQuery = AdminPageHelper.normalize(body == null ? null : body.getPage());
        Long senderId = body != null ? body.getSenderId() : null;
        Long recipientId = body != null ? body.getRecipientId() : null;
        Integer status = body != null ? body.getStatus() : null;
        Page<TimeLetterDomain> p = timeLetterService.pageForAdmin(pageQuery, senderId, recipientId, status);
        List<TimeLetterDTO> list = p.getRecords().stream().map(this::toDto).collect(Collectors.toList());
        return AdminPageHelper.pageData(pageQuery, p, list);
    }

    /**
     * 查询时光信详情；不存在则抛错。
     */
    public TimeLetterDTO getDetail(long id) {
        TimeLetterDomain d = timeLetterService.getById(id);
        if (d == null || d.isDelFlag()) {
            throw new BadRequestException("时光信不存在");
        }
        return toDto(d);
    }

    /**
     * 下架时光信并记录原因。
     */
    @Transactional(rollbackFor = Exception.class)
    public void takedown(long id, String reason) {
        if (!StringUtils.hasText(reason)) {
            throw new BadRequestException("下架原因不能为空");
        }
        boolean ok = timeLetterService.adminTakedown(id, reason.trim(), LocalDateTime.now());
        if (!ok) {
            throw new BadRequestException("时光信不存在或已删除");
        }
        log.info("time-letter takedown, letterId={}", id);
    }

    /**
     * Domain 转管理端 DTO（含正文，仅后台使用）。
     */
    public TimeLetterDTO toDto(TimeLetterDomain d) {
        TimeLetterDTO dto = new TimeLetterDTO();
        dto.setId(d.getId());
        dto.setSenderId(d.getSenderId());
        dto.setRecipientId(d.getRecipientId());
        dto.setRecipientType(d.getRecipientType());
        dto.setBody(d.getBody());
        dto.setDeliveryDate(d.getDeliveryDate());
        dto.setDeliveryTz(d.getDeliveryTz());
        dto.setStatus(d.getStatus());
        dto.setSealedAt(d.getSealedAt());
        dto.setDeliveredAt(d.getDeliveredAt());
        dto.setReadAt(d.getReadAt());
        dto.setStampCost(d.getStampCost());
        dto.setStarFlag(d.getStarFlag());
        dto.setFailReason(d.getFailReason());
        dto.setTakedownReason(d.getTakedownReason());
        dto.setCreatedAt(d.getCreatedAt());
        dto.setUpdatedAt(d.getUpdatedAt());
        return dto;
    }
}
