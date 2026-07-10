package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.DailyRecommendationDomain;
import com.baomidou.mybatisplus.extension.service.IService;

import java.time.LocalDate;
import java.util.List;

public interface DailyRecommendationService extends IService<DailyRecommendationDomain> {

    List<DailyRecommendationDomain> listForUserOnDate(long userId, LocalDate date);

    boolean existsForUserOnDate(long userId, LocalDate date);
}
