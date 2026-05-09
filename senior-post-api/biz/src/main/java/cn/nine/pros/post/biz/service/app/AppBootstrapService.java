package cn.nine.pros.post.biz.service.app;

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

    private static final Set<String> VIP_PRODUCT_KEYS = Set.of(
            "vip.product.enabled",
            "vip.product.display_name",
            "vip.product.tagline",
            "vip.product.tagline_zh",
            "vip.benefit.unlimited_stamps",
            "vip.benefit.standard_delivery_hours");

    private final ConfigService configService;
    private final CountryService countryService;
    private final AppDirectoryService appDirectoryService;

    public AppBootstrapService(
            ConfigService configService,
            CountryService countryService,
            AppDirectoryService appDirectoryService) {
        this.configService = configService;
        this.countryService = countryService;
        this.appDirectoryService = appDirectoryService;
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
                .displayName(firstNonBlank(map.get("vip.product.display_name"), "VIP"))
                .tagline(firstNonBlank(
                        map.get("vip.product.tagline"),
                        "Unlimited stamps · Priority delivery · Ad-free"))
                .taglineZh(firstNonBlank(
                        map.get("vip.product.tagline_zh"),
                        "无限邮票 · 优先送达 · 无广告干扰"))
                .unlimitedStampsBenefit(parseBoolean(map.get("vip.benefit.unlimited_stamps"), true))
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
}
