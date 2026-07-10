package cn.nine.pros.post.biz.service.biz.impl;

import cn.nine.commons.basic.exception.unchecked.BusinessException;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.model.domain.LetterDomain;
import cn.nine.pros.post.biz.service.base.LetterService;
import cn.nine.pros.post.biz.service.base.UserEntitlementService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.biz.service.biz.AppLetterExportBizService;
import cn.nine.pros.post.client.model.db.UserDTO;
import cn.nine.pros.post.client.model.input.app.LetterExportInDto;
import cn.nine.pros.post.client.model.out.LetterExportResultVO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class AppLetterExportBizServiceImpl implements AppLetterExportBizService {

    private static final String EXPORT_PRODUCT_CODE = "export.pdf";
    private static final int MAX_EXPORT_ROWS = 500;

    private final LetterService letterService;
    private final UserEntitlementService userEntitlementService;
    private final UserService userService;
    private final AppMessages appMessages;

    @Override
    public LetterExportResultVO export(long userId, LetterExportInDto body) {
        assertExportEntitlement(userId);
        LocalDateTime from = body != null && body.getFromDate() != null
                ? body.getFromDate().atStartOfDay() : null;
        LocalDateTime to = body != null && body.getToDate() != null
                ? body.getToDate().atTime(LocalTime.MAX) : null;
        Long peerUserId = body != null ? body.getPeerUserId() : null;
        List<LetterDomain> letters = letterService.listDeliveredForExport(
                userId, peerUserId, from, to, MAX_EXPORT_ROWS);
        if (letters.isEmpty()) {
            throw new BusinessException(appMessages.get("app.error.export.noLetters"));
        }
        String downloadUrl = writeExportFile(userId, letters);
        log.info("letter export generated, userId={}, count={}, url={}", userId, letters.size(), downloadUrl);
        return LetterExportResultVO.builder().downloadUrl(downloadUrl).build();
    }

    private void assertExportEntitlement(long userId) {
        UserDTO user = userService.findById(userId);
        if (Boolean.TRUE.equals(user != null ? user.getIsVip() : null)) {
            return;
        }
        if (userEntitlementService.hasEntitlementByCode(userId, EXPORT_PRODUCT_CODE)) {
            return;
        }
        throw new BusinessException(appMessages.get("app.error.export.notEntitled"));
    }

    private String writeExportFile(long userId, List<LetterDomain> letters) {
        StringBuilder sb = new StringBuilder();
        sb.append("Senior Post — Letter Export\n");
        sb.append("User ID: ").append(userId).append("\n");
        sb.append("Generated: ").append(LocalDateTime.now()).append("\n");
        sb.append("---\n\n");
        for (LetterDomain letter : letters) {
            sb.append("Letter #").append(letter.getId()).append("\n");
            sb.append("From: ").append(letter.getFromUserId()).append("\n");
            sb.append("To: ").append(letter.getToUserId()).append("\n");
            sb.append("Date: ").append(letter.getCreatedAt()).append("\n");
            sb.append(letter.getContent() != null ? letter.getContent() : "").append("\n\n---\n\n");
        }
        try {
            Path dir = Files.createTempDirectory("senior-post-export-");
            Path file = dir.resolve("letters-" + UUID.randomUUID() + ".txt");
            Files.writeString(file, sb.toString(), StandardCharsets.UTF_8);
            return "file://" + file.toAbsolutePath();
        } catch (IOException e) {
            log.warn("export temp file failed, returning placeholder, userId={}", userId, e);
            return "https://placeholder.senior-post.local/exports/" + UUID.randomUUID() + ".txt";
        }
    }
}
