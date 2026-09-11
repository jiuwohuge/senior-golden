package cn.nine.pros.post.biz.billing;

import cn.nine.commons.basic.exception.unchecked.BusinessException;
import cn.nine.pros.post.biz.i18n.AppMessages;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * BillingProvider 注册表：按 providerName 解析实现。
 */
@Slf4j
@Component
public class BillingProviderRegistry {

    private final Map<String, BillingProvider> providers;
    private final AppMessages appMessages;

    public BillingProviderRegistry(List<BillingProvider> providerList, AppMessages appMessages) {
        this.appMessages = appMessages;
        this.providers = providerList.stream()
                .collect(Collectors.toMap(
                        p -> p.providerName().toLowerCase(Locale.ROOT),
                        Function.identity(),
                        (a, b) -> a));
        log.info("billing providers registered: {}", providers.keySet());
    }

    /**
     * 按名称获取 provider；未知则抛业务异常。
     */
    public BillingProvider getRequired(String providerName) {
        if (!StringUtils.hasText(providerName)) {
            throw new BusinessException(appMessages.get("app.error.billing.invalidRequest"));
        }
        BillingProvider provider = providers.get(providerName.trim().toLowerCase(Locale.ROOT));
        if (provider == null) {
            throw new BusinessException(appMessages.get("app.error.billing.invalidRequest"));
        }
        return provider;
    }
}
