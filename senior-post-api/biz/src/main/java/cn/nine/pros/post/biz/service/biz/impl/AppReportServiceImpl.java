package cn.nine.pros.post.biz.service.biz.impl;

import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.model.domain.ReportDomain;
import cn.nine.pros.post.biz.service.biz.AppReportService;
import cn.nine.pros.post.biz.service.base.ReportService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.client.model.db.UserDTO;
import cn.nine.pros.post.client.model.input.app.AppReportCreateInDto;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.Objects;

@Service
@RequiredArgsConstructor
public class AppReportServiceImpl implements AppReportService {

    private static final String TYPE_USER = "user";

    private final ReportService reportService;
    private final UserService userService;
    private final AppMessages appMessages;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void submit(long reporterUserId, AppReportCreateInDto body) {
        String rawType = body.getTargetType() == null ? "" : body.getTargetType().trim().toLowerCase();
        if (!TYPE_USER.equals(rawType)) {
            throw new BadRequestException(appMessages.get("app.error.report.targetType"));
        }
        String reason = body.getReason() == null ? "" : body.getReason().trim();
        if (!StringUtils.hasText(reason)) {
            throw new BadRequestException(appMessages.get("app.error.report.reasonEmpty"));
        }
        if (body.getTargetId() == null) {
            throw new BadRequestException(appMessages.get("app.error.report.targetIdEmpty"));
        }
        validateUserTarget(reporterUserId, body.getTargetId());

        long pending = reportService.countPendingByReporterTarget(reporterUserId, rawType, body.getTargetId());
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

    private void validateUserTarget(long reporterUserId, long reportedUserId) {
        if (Objects.equals(reporterUserId, reportedUserId)) {
            throw new BadRequestException(appMessages.get("app.error.report.ownUser"));
        }
        UserDTO u = userService.findById(reportedUserId);
        if (u == null) {
            throw new BadRequestException(appMessages.get("app.error.report.userNotFound"));
        }
    }
}
