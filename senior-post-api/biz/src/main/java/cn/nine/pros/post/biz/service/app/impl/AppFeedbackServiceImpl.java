package cn.nine.pros.post.biz.service.app.impl;

import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.mapper.AppFeedbackMapper;
import cn.nine.pros.post.biz.model.domain.AppFeedbackDomain;
import cn.nine.pros.post.biz.service.app.AppFeedbackService;
import cn.nine.pros.post.client.model.input.app.AppFeedbackSubmitInDto;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
@RequiredArgsConstructor
public class AppFeedbackServiceImpl implements AppFeedbackService {

    private final AppFeedbackMapper appFeedbackMapper;
    private final AppMessages appMessages;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void submit(long userId, AppFeedbackSubmitInDto body) {
        String text = body.getContent() == null ? "" : body.getContent().trim();
        if (!StringUtils.hasText(text)) {
            throw new BadRequestException(appMessages.get("app.error.feedback.empty"));
        }
        AppFeedbackDomain d = new AppFeedbackDomain();
        d.setUserId(userId);
        d.setContent(text);
        d.setClientVersion(StringUtils.hasText(body.getClientVersion()) ? body.getClientVersion().trim() : null);
        d.initAudit(userId);
        appFeedbackMapper.insert(d);
    }
}
