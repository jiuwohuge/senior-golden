package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.pros.post.biz.mapper.DailyRecommendationMapper;
import cn.nine.pros.post.biz.model.domain.DailyRecommendationDomain;
import cn.nine.pros.post.biz.service.base.DailyRecommendationService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@Service
public class DailyRecommendationServiceImpl extends ServiceImpl<DailyRecommendationMapper, DailyRecommendationDomain>
        implements DailyRecommendationService {

    @Override
    public List<DailyRecommendationDomain> listForUserOnDate(long userId, LocalDate date) {
        return list(new LambdaQueryWrapper<DailyRecommendationDomain>()
                .eq(DailyRecommendationDomain::getUserId, userId)
                .eq(DailyRecommendationDomain::getRecommendDate, date)
                .eq(DailyRecommendationDomain::isDelFlag, false)
                .orderByDesc(DailyRecommendationDomain::getScore));
    }

    @Override
    public boolean existsForUserOnDate(long userId, LocalDate date) {
        return count(new LambdaQueryWrapper<DailyRecommendationDomain>()
                .eq(DailyRecommendationDomain::getUserId, userId)
                .eq(DailyRecommendationDomain::getRecommendDate, date)
                .eq(DailyRecommendationDomain::isDelFlag, false)) > 0;
    }
}
