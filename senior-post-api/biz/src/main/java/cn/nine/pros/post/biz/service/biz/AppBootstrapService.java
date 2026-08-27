package cn.nine.pros.post.biz.service.biz;

import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.model.domain.ConfigDomain;
import cn.nine.pros.post.biz.model.domain.TagDomain;
import cn.nine.pros.post.biz.service.base.ConfigService;
import cn.nine.pros.post.biz.service.base.CountryService;
import cn.nine.pros.post.biz.service.base.TagService;
import cn.nine.pros.post.client.model.out.AppBootstrapVO;
import cn.nine.pros.post.client.model.out.AppCountryVO;
import cn.nine.pros.post.client.model.out.AppVipProductConfigVO;
import cn.nine.pros.post.client.model.out.InterestTagOptionVO;
import cn.nine.pros.post.client.model.out.LetterTopicOptionVO;
import org.springframework.util.StringUtils;
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

    private static final String TERMS_URL_KEY = "legal.terms_url";
    private static final String PRIVACY_URL_KEY = "legal.privacy_url";
    private static final Set<String> LEGAL_URL_KEYS = Set.of(TERMS_URL_KEY, PRIVACY_URL_KEY);

    private static final Set<String> VIP_PRODUCT_KEYS = Set.of(
            "vip.product.enabled",
            "vip.product.display_name",
            "vip.product.tagline",
            "vip.product.tagline_zh");

    private final ConfigService configService;
    private final CountryService countryService;
    private final AppDirectoryService appDirectoryService;
    private final TagService tagService;
    private final AppMessages appMessages;

    public AppBootstrapService(
            ConfigService configService,
            CountryService countryService,
            AppDirectoryService appDirectoryService,
            TagService tagService,
            AppMessages appMessages) {
        this.configService = configService;
        this.countryService = countryService;
        this.appDirectoryService = appDirectoryService;
        this.tagService = tagService;
        this.appMessages = appMessages;
    }

    /**
     * 启动配置：注册门槛、国家、兴趣选项、写信主题邮票、VIP 展示与日额度。
     * <p>匿名可读；无写库副作用。
     */
    public AppBootstrapVO init(String langCode) {
        List<AppCountryVO> countries = countryService.listActiveOrdered().stream()
                .map(country -> AppCountryVO.builder()
                        .code(country.getCountryCode())
                        .nameEn(country.getCountryNameEn())
                        .nameZh(country.getCountryNameZh())
                        .build())
                .toList();
        List<InterestTagOptionVO> interestOpts = appDirectoryService.listInterestTagOptions(langCode);
        Map<String, String> legalUrls = loadLegalUrls();
        return AppBootstrapVO.builder()
                .minRegisterAge(configService.getInt(REGISTER_MIN_AGE_KEY, DEFAULT_MIN_AGE))
                .countries(countries)
                .interestTagOptions(interestOpts)
                .letterTopicOptions(loadLetterTopicOptions(langCode))
                .vipProduct(loadVipProductConfig())
                .dailyLetterQuota(configService.getInt(LETTER_DAILY_QUOTA_KEY, DEFAULT_DAILY_LETTER_QUOTA))
                .termsUrl(safeHttpUrl(legalUrls.get(TERMS_URL_KEY)))
                .privacyUrl(safeHttpUrl(legalUrls.get(PRIVACY_URL_KEY)))
                .build();
    }

    private Map<String, String> loadLegalUrls() {
        Map<String, String> map = new HashMap<>();
        for (ConfigDomain row : configService.listActiveByKeys(LEGAL_URL_KEYS)) {
            if (StringUtils.hasText(row.getConfigKey()) && StringUtils.hasText(row.getConfigValue())) {
                map.put(row.getConfigKey(), row.getConfigValue().trim());
            }
        }
        return map;
    }

    private static String safeHttpUrl(String raw) {
        if (!StringUtils.hasText(raw)) {
            return "";
        }
        String value = raw.trim();
        return value.startsWith("https://") || value.startsWith("http://") ? value : "";
    }

    /**
     * 写信主题邮票：按请求语言；空则回退 en，避免客户端写死数字 id。
     */
    private List<LetterTopicOptionVO> loadLetterTopicOptions(String langCode) {
        String lang = StringUtils.hasText(langCode) ? langCode.trim().toLowerCase() : "en";
        List<LetterTopicOptionVO> primary = mapLetterTopics(tagService.listActiveLetterTopicsByLang(lang));
        if (!primary.isEmpty()) {
            return primary;
        }
        if (!"en".equals(lang)) {
            return mapLetterTopics(tagService.listActiveLetterTopicsByLang("en"));
        }
        return List.of();
    }

    private static List<LetterTopicOptionVO> mapLetterTopics(List<TagDomain> rows) {
        return rows.stream()
                .filter(t -> t.getId() != null && StringUtils.hasText(t.getTagName()))
                .map(t -> LetterTopicOptionVO.builder()
                        .id(t.getId())
                        .code(t.getTagCode())
                        .title(t.getTagName().trim())
                        .build())
                .toList();
    }

    private AppVipProductConfigVO loadVipProductConfig() {
        List<ConfigDomain> rows = configService.listActiveByKeys(VIP_PRODUCT_KEYS);
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

}
