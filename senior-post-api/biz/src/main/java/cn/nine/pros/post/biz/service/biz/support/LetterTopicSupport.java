package cn.nine.pros.post.biz.service.biz.support;

import cn.nine.commons.basic.exception.unchecked.BusinessException;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.model.domain.TagDomain;
import cn.nine.pros.post.biz.service.base.TagService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

/**
 * 写信主题邮票校验：可选；非空必须是未删除的 letter_topic。
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class LetterTopicSupport {

    public static final String KIND_INTEREST = "interest";
    public static final String KIND_LETTER_TOPIC = "letter_topic";

    private final TagService tagService;
    private final AppMessages appMessages;

    /**
     * 校验可选主题 id。空则原样返回 null；非法则 4501。
     *
     * @param userId     发件人，仅用于日志
     * @param topicTagId 客户端回传的 sys_tag.id
     */
    public Integer requireLetterTopicIdOrNull(long userId, Integer topicTagId) {
        if (topicTagId == null) {
            return null;
        }
        TagDomain tag = tagService.getById(topicTagId);
        if (tag == null || tag.isDelFlag()
                || !KIND_LETTER_TOPIC.equals(tag.getTagKind())) {
            log.info("letter topic rejected: invalid id, userId={}, topicTagId={}", userId, topicTagId);
            throw new BusinessException(appMessages.get("app.error.letter.topicInvalid"));
        }
        return topicTagId;
    }

    /** 兴趣目录：仅 interest（旧数据 tagKind 为空也视为兴趣）。 */
    public static boolean isInterestTag(TagDomain tag) {
        if (tag == null) {
            return false;
        }
        if (!StringUtils.hasText(tag.getTagKind())) {
            return true;
        }
        return KIND_INTEREST.equals(tag.getTagKind());
    }
}

