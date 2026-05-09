package cn.nine.pros.post.biz.service.app.impl;

import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.i18n.AppMessages;
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
    private final AppMessages appMessages;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void submit(long reporterUserId, AppReportCreateInDto body) {
        String rawType = body.getTargetType() == null ? "" : body.getTargetType().trim().toLowerCase();
        if (!TYPE_POSTCARD.equals(rawType) && !TYPE_COMMENT.equals(rawType)) {
            throw new BadRequestException(appMessages.get("app.error.report.targetType"));
        }
        String reason = body.getReason() == null ? "" : body.getReason().trim();
        if (!StringUtils.hasText(reason)) {
            throw new BadRequestException(appMessages.get("app.error.report.reasonEmpty"));
        }
        if (body.getTargetId() == null) {
            throw new BadRequestException(appMessages.get("app.error.report.targetIdEmpty"));
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
            throw new BadRequestException(appMessages.get("app.error.report.pendingDuplicate"));
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
            throw new BadRequestException(appMessages.get("app.error.report.postcardNotFound"));
        }
        if (Objects.equals(reporterUserId, p.getUserId())) {
            throw new BadRequestException(appMessages.get("app.error.report.ownPostcard"));
        }
    }

    private void validateCommentTarget(long reporterUserId, long commentId) {
        PostcardCommentDomain c = postcardCommentService.getById(commentId);
        if (c == null || c.isDelFlag()) {
            throw new BadRequestException(appMessages.get("app.error.report.commentNotFound"));
        }
        if (Objects.equals(reporterUserId, c.getUserId())) {
            throw new BadRequestException(appMessages.get("app.error.report.ownComment"));
        }
    }
}
