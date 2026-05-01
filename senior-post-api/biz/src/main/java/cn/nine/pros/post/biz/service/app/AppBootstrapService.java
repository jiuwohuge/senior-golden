package cn.nine.pros.post.biz.service.app;

import cn.nine.pros.post.biz.model.domain.ConfigDomain;
import cn.nine.pros.post.biz.model.domain.CountryDomain;
import cn.nine.pros.post.biz.service.base.ConfigService;
import cn.nine.pros.post.biz.service.base.CountryService;
import cn.nine.pros.post.client.model.out.AppBootstrapVO;
import cn.nine.pros.post.client.model.out.AppCountryVO;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class AppBootstrapService {

    private static final String REGISTER_MIN_AGE_KEY = "register.min_age";
    private static final int DEFAULT_MIN_AGE = 45;

    private final ConfigService configService;
    private final CountryService countryService;

    public AppBootstrapService(ConfigService configService, CountryService countryService) {
        this.configService = configService;
        this.countryService = countryService;
    }

    public AppBootstrapVO init() {
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
        return AppBootstrapVO.builder()
                .minRegisterAge(minAge)
                .countries(countries)
                .build();
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
