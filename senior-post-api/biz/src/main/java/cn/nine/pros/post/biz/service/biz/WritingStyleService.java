package cn.nine.pros.post.biz.service.biz;

import cn.nine.pros.post.biz.model.domain.LetterDomain;
import cn.nine.pros.post.biz.service.base.LetterService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.biz.service.biz.support.WritingStyleAnalyzer;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 写作风格规则版：累计发信后按正文重算 concise|narrative|emotional。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class WritingStyleService {

    private static final int MIN_LETTERS = 1;
    private static final int SAMPLE_LIMIT = 20;

    private final LetterService letterService;
    private final UserService userService;

    /**
     * 根据用户最近发出信件正文重算 writing_style；样本不足则跳过。
     */
    public void recompute(long userId) {
        List<LetterDomain> letters = letterService.listRecentByFromUser(userId, SAMPLE_LIMIT);
        if (letters.size() < MIN_LETTERS) {
            return;
        }
        String joined = letters.stream()
                .map(LetterDomain::getContent)
                .filter(StringUtils::hasText)
                .collect(Collectors.joining("\n"));
        if (!StringUtils.hasText(joined)) {
            return;
        }
        String style = WritingStyleAnalyzer.classify(joined);
        userService.updateWritingStyle(userId, style);
        log.info("writing style updated, userId={}, style={}", userId, style);
    }
}
