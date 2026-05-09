package cn.nine.pros.post.biz.i18n;

import lombok.RequiredArgsConstructor;
import org.springframework.context.MessageSource;
import org.springframework.context.i18n.LocaleContextHolder;
import org.springframework.stereotype.Component;

/**
 * App（/api）用户可见错误文案。依赖请求级 {@link org.springframework.context.i18n.LocaleContextHolder}
 *（由 Accept-Language 等解析；默认 zh_CN 以兼容管理端未带头时的历史行为）。
 */
@Component
@RequiredArgsConstructor
public class AppMessages {

    private final MessageSource messageSource;

    public String get(String code, Object... args) {
        return messageSource.getMessage(code, args == null || args.length == 0 ? null : args,
                LocaleContextHolder.getLocale());
    }
}
