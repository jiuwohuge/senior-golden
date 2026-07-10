package cn.nine.pros.post.biz.service.biz.admin;

import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.model.domain.TimeLetterDomain;
import cn.nine.pros.post.biz.service.base.TimeLetterService;
import cn.nine.pros.post.client.common.enums.TimeLetterStatus;
import cn.nine.pros.post.client.model.db.TimeLetterDTO;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class AdminTimeLetterService {

    private final TimeLetterService timeLetterService;

    public TimeLetterDTO getDetail(long id) {
        TimeLetterDomain d = timeLetterService.getById(id);
        if (d == null || d.isDelFlag()) {
            throw new BadRequestException("时光信不存在");
        }
        return toDto(d);
    }

    @Transactional(rollbackFor = Exception.class)
    public void takedown(long id, String reason) {
        if (!StringUtils.hasText(reason)) {
            throw new BadRequestException("下架原因不能为空");
        }
        LocalDateTime now = LocalDateTime.now();
        boolean ok = timeLetterService.update(new LambdaUpdateWrapper<TimeLetterDomain>()
                .eq(TimeLetterDomain::getId, id)
                .eq(TimeLetterDomain::isDelFlag, false)
                .set(TimeLetterDomain::getTakedownReason, reason.trim())
                .set(TimeLetterDomain::getStatus, TimeLetterStatus.FAILED.getCode())
                .set(TimeLetterDomain::getUpdatedAt, now)
                .set(TimeLetterDomain::getUpdatedBy, 0L));
        if (!ok) {
            throw new BadRequestException("时光信不存在或已删除");
        }
    }

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
