package cn.nine.pros.post.biz.service.app.impl;

import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.model.domain.PostcardCommentDomain;
import cn.nine.pros.post.biz.model.domain.PostcardDomain;
import cn.nine.pros.post.biz.model.domain.ReportDomain;
import cn.nine.pros.post.biz.service.app.AppReportService;
import cn.nine.pros.post.biz.service.base.PostcardCommentService;
import cn.nine.pros.post.biz.service.base.PostcardService;
import cn.nine.pros.post.biz.service.base.ReportService;
import cn.nine.pros.post.client.model.input.app.AppReportCreateInDto;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;

import java.util.Objects;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
@RequiredArgsConstructor
public class AppReportServiceImpl implements AppReportService {

    private static final String TYPE_POSTCARD = "postcard";
    private static final String TYPE_COMMENT = "comment";

    private final ReportService reportService;
    private final PostcardService postcardService;
    private final PostcardCommentService postcardCommentService;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void submit(long reporterUserId, AppReportCreateInDto body) {
        String rawType = body.getTargetType() == null ? "" : body.getTargetType().trim().toLowerCase();
        if (!TYPE_POSTCARD.equals(rawType) && !TYPE_COMMENT.equals(rawType)) {
            throw new BadRequestException("targetType 须为 postcard 或 comment");
        }
        String reason = body.getReason() == null ? "" : body.getReason().trim();
        if (!StringUtils.hasText(reason)) {
            throw new BadRequestException("举报原因不能为空");
        }
        if (body.getTargetId() == null) {
            throw new BadRequestException("targetId 不能为空");
        }
        if (TYPE_POSTCARD.equals(rawType)) {
            validatePostcardTarget(reporterUserId, body.getTargetId());
        } else {
            validateCommentTarget(reporterUserId, body.getTargetId());
        }

        long pending = reportService.count(new LambdaQueryWrapper<ReportDomain>()
                .eq(ReportDomain::isDelFlag, false)
                .eq(ReportDomain::getReporterUserId, reporterUserId)
                .eq(ReportDomain::getTargetType, rawType)
                .eq(ReportDomain::getTargetId, body.getTargetId())
                .apply("status = 0"));
        if (pending > 0) {
            throw new BadRequestException("该对象已有您提交的待处理举报");
        }

        String storedReason = reason.length() > 255 ? reason.substring(0, 255) : reason;
        ReportDomain d = new ReportDomain();
        d.setReporterUserId(reporterUserId);
        d.setTargetType(rawType);
        d.setTargetId(body.getTargetId());
        d.setReason(storedReason);
        d.setStatus(0);
        d.initAudit(reporterUserId);
        reportService.save(d);
    }

    private void validatePostcardTarget(long reporterUserId, long postcardId) {
        PostcardDomain p = postcardService.getById(postcardId);
        if (p == null || p.isDelFlag()) {
            throw new BadRequestException("明信片不存在");
        }
        if (Objects.equals(reporterUserId, p.getUserId())) {
            throw new BadRequestException("不能举报自己的明信片");
        }
    }

    private void validateCommentTarget(long reporterUserId, long commentId) {
        PostcardCommentDomain c = postcardCommentService.getById(commentId);
        if (c == null || c.isDelFlag()) {
            throw new BadRequestException("评论不存在");
        }
        if (Objects.equals(reporterUserId, c.getUserId())) {
            throw new BadRequestException("不能举报自己的评论");
        }
    }
}
