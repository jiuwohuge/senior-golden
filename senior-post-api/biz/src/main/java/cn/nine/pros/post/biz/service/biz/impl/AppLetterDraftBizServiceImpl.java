package cn.nine.pros.post.biz.service.biz.impl;

import cn.nine.commons.basic.exception.unchecked.BusinessException;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.model.domain.LetterDraftDomain;
import cn.nine.pros.post.biz.service.base.LetterDraftService;
import cn.nine.pros.post.biz.service.biz.AppLetterDraftBizService;
import cn.nine.pros.post.biz.service.biz.AppMailboxService;
import cn.nine.pros.post.client.common.enums.LetterMode;
import cn.nine.pros.post.client.model.input.app.AppSendLetterInDto;
import cn.nine.pros.post.client.model.input.app.LetterDraftSaveInDto;
import cn.nine.pros.post.client.model.json.LetterDraftContent;
import cn.nine.pros.post.client.model.out.LetterDraftVO;
import cn.nine.pros.post.client.model.out.MailboxLetterItemVO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class AppLetterDraftBizServiceImpl implements AppLetterDraftBizService {

    private static final String DEFAULT_MODE = "DIRECT";
    private static final int DEFAULT_LETTER_TYPE = 2;

    private final LetterDraftService letterDraftService;
    private final AppMailboxService appMailboxService;
    private final AppMessages appMessages;

    @Override
    public List<LetterDraftVO> listDrafts(long userId) {
        return letterDraftService.listForUser(userId).stream()
                .map(this::toVo)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public LetterDraftVO saveDraft(long userId, LetterDraftSaveInDto body) {
        if (body == null) {
            throw new BusinessException(appMessages.get("app.error.draft.invalid"));
        }
        LetterDraftDomain draft = new LetterDraftDomain();
        draft.setId(body.getId());
        draft.setUserId(userId);
        draft.setMode(StringUtils.hasText(body.getMode()) ? body.getMode().trim().toUpperCase() : DEFAULT_MODE);
        draft.setToUserId(body.getToUserId());
        draft.setContentJson(body.getContentJson() != null ? body.getContentJson() : new LetterDraftContent());
        LetterDraftDomain saved = letterDraftService.saveOwned(draft, userId);
        if (saved == null) {
            throw new BusinessException(appMessages.get("app.error.draft.notFound"));
        }
        log.info("letter draft saved, userId={}, draftId={}", userId, saved.getId());
        return toVo(saved);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteDraft(long userId, long draftId) {
        LetterDraftDomain owned = letterDraftService.findOwned(userId, draftId);
        if (owned == null) {
            throw new BusinessException(appMessages.get("app.error.draft.notFound"));
        }
        letterDraftService.softDeleteOwned(userId, draftId);
        log.info("letter draft deleted, userId={}, draftId={}", userId, draftId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public MailboxLetterItemVO sendDraft(long userId, long draftId) {
        LetterDraftDomain draft = letterDraftService.findOwned(userId, draftId);
        if (draft == null) {
            throw new BusinessException(appMessages.get("app.error.draft.notFound"));
        }
        AppSendLetterInDto send = toSendDto(draft);
        MailboxLetterItemVO sent = appMailboxService.sendLetter(userId, send);
        letterDraftService.softDeleteOwned(userId, draftId);
        log.info("letter draft sent, userId={}, draftId={}, letterId={}", userId, draftId, sent.getLetterId());
        return sent;
    }

    private AppSendLetterInDto toSendDto(LetterDraftDomain draft) {
        LetterDraftContent json = draft.getContentJson() != null ? draft.getContentJson() : new LetterDraftContent();
        if (!StringUtils.hasText(json.getContent())) {
            throw new BusinessException(appMessages.get("app.error.letter.contentEmpty"));
        }
        AppSendLetterInDto send = new AppSendLetterInDto();
        send.setContent(json.getContent().trim());
        send.setLetterType(json.getLetterType() != null ? json.getLetterType() : DEFAULT_LETTER_TYPE);
        send.setToUserId(draft.getToUserId());
        send.setParentLetterId(json.getParentLetterId());
        send.setMode(resolveModeCode(draft.getMode()));
        send.setSkinId(json.getSkinId());
        send.setFontId(json.getFontId());
        send.setTemplateId(json.getTemplateId());
        return send;
    }

    private static Integer resolveModeCode(String mode) {
        if (!StringUtils.hasText(mode)) {
            return null;
        }
        String normalized = mode.trim().toUpperCase();
        if ("POST_OFFICE".equals(normalized)) {
            return LetterMode.POST_OFFICE.getCode();
        }
        if ("DIRECT".equals(normalized)) {
            return LetterMode.DIRECT.getCode();
        }
        return null;
    }

    private LetterDraftVO toVo(LetterDraftDomain d) {
        return LetterDraftVO.builder()
                .id(d.getId())
                .mode(d.getMode())
                .toUserId(d.getToUserId())
                .contentJson(d.getContentJson())
                .updatedAt(d.getUpdatedAt())
                .build();
    }
}
