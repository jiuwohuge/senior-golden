package cn.nine.pros.post.biz.service.biz;

import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.model.domain.ConfigDomain;
import cn.nine.pros.post.biz.model.domain.CountryDomain;
import cn.nine.pros.post.biz.service.base.ConfigService;
import cn.nine.pros.post.biz.service.base.CountryService;
import cn.nine.pros.post.client.model.out.AppBootstrapVO;
import cn.nine.pros.post.client.model.out.AppCountryVO;
import cn.nine.pros.post.client.model.out.AppVipProductConfigVO;
import cn.nine.pros.post.client.model.out.InterestTagOptionVO;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

@Service
public class AppBootstrapService {

    private static final String REGISTER_MIN_AGE_KEY = "register.min_age";
    private static final int DEFAULT_MIN_AGE = 45;

    private static final String LETTER_DAILY_QUOTA_KEY = "letter.daily_quota";
    private static final int DEFAULT_DAILY_LETTER_QUOTA = 5;

    private static final Set<String> VIP_PRODUCT_KEYS = Set.of(
            "vip.product.enabled",
            "vip.product.display_name",
            "vip.product.tagline",
            "vip.product.tagline_zh",
            "vip.benefit.standard_delivery_hours");

    private final ConfigService configService;
    private final CountryService countryService;
    private final AppDirectoryService appDirectoryService;
    private final AppMessages appMessages;

    public AppBootstrapService(
            ConfigService configService,
            CountryService countryService,
            AppDirectoryService appDirectoryService,
            AppMessages appMessages) {
        this.configService = configService;
        this.countryService = countryService;
        this.appDirectoryService = appDirectoryService;
        this.appMessages = appMessages;
    }

    public AppBootstrapVO init(String langCode) {
        Integer minAge = loadMinAge();
        List<AppCountryVO> countries = countryService.list(
                        new LambdaQueryWrapper<CountryDomain>()
                                .eq(CountryDomain::isDelFlag, false)
                                .orderByAsc(CountryDomain::getSortOrder)
                                .orderByAsc(CountryDomain::getId))
                .stream()
                .map(country -> AppCountryVO.builder()
                        .code(country.getCountryCode())
                        .nameEn(country.getCountryNameEn())
                        .nameZh(country.getCountryNameZh())
                        .build())
                .toList();
        List<InterestTagOptionVO> interestOpts = appDirectoryService.listInterestTagOptions(langCode);
        return AppBootstrapVO.builder()
                .minRegisterAge(minAge)
                .countries(countries)
                .interestTagOptions(interestOpts)
                .vipProduct(loadVipProductConfig())
                .dailyLetterQuota(loadDailyLetterQuota())
                .build();
    }

    private AppVipProductConfigVO loadVipProductConfig() {
        List<ConfigDomain> rows = configService.list(
                new LambdaQueryWrapper<ConfigDomain>()
                        .eq(ConfigDomain::isDelFlag, false)
                        .in(ConfigDomain::getConfigKey, VIP_PRODUCT_KEYS));
        Map<String, String> map = new HashMap<>();
        for (ConfigDomain row : rows) {
            if (row.getConfigKey() != null && row.getConfigValue() != null) {
                map.put(row.getConfigKey(), row.getConfigValue());
            }
        }
        return AppVipProductConfigVO.builder()
                .productEnabled(parseBoolean(map.get("vip.product.enabled"), true))
                .displayName(firstNonBlank(map.get("vip.product.display_name"),
                        appMessages.get("app.bootstrap.vip.displayNameDefault")))
                .tagline(firstNonBlank(
                        map.get("vip.product.tagline"),
                        appMessages.get("app.bootstrap.vip.taglineDefault")))
                .taglineZh(firstNonBlank(
                        map.get("vip.product.tagline_zh"),
                        appMessages.get("app.bootstrap.vip.taglineZhDefault")))
                .standardDeliveryHours(parseInt(map.get("vip.benefit.standard_delivery_hours"), 0))
                .build();
    }

    private static String firstNonBlank(String v, String dft) {
        if (v == null || v.isBlank()) {
            return dft;
        }
        return v.trim();
    }

    private static boolean parseBoolean(String raw, boolean dft) {
        if (raw == null || raw.isBlank()) {
            return dft;
        }
        return Boolean.parseBoolean(raw.trim());
    }

    private static int parseInt(String raw, int dft) {
        if (raw == null || raw.isBlank()) {
            return dft;
        }
        try {
            return Integer.parseInt(raw.trim());
        } catch (NumberFormatException e) {
            return dft;
        }
    }

    private Integer loadMinAge() {
        ConfigDomain cfg = configService.getOne(
                new LambdaQueryWrapper<ConfigDomain>()
                        .eq(ConfigDomain::isDelFlag, false)
                        .eq(ConfigDomain::getConfigKey, REGISTER_MIN_AGE_KEY)
                        .last("limit 1"));
        if (cfg == null || cfg.getConfigValue() == null || cfg.getConfigValue().isBlank()) {
            return DEFAULT_MIN_AGE;
        }
        try {
            return Integer.parseInt(cfg.getConfigValue().trim());
        } catch (NumberFormatException ignore) {
            return DEFAULT_MIN_AGE;
        }
    }

    private Integer loadDailyLetterQuota() {
        ConfigDomain cfg = configService.getOne(
                new LambdaQueryWrapper<ConfigDomain>()
                        .eq(ConfigDomain::isDelFlag, false)
                        .eq(ConfigDomain::getConfigKey, LETTER_DAILY_QUOTA_KEY)
                        .last("limit 1"));
        if (cfg == null || cfg.getConfigValue() == null || cfg.getConfigValue().isBlank()) {
            return DEFAULT_DAILY_LETTER_QUOTA;
        }
        try {
            return Integer.parseInt(cfg.getConfigValue().trim());
        } catch (NumberFormatException ignore) {
            return DEFAULT_DAILY_LETTER_QUOTA;
        }
    }

}
