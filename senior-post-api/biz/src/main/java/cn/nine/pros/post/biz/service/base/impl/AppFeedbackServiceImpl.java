package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.support.PageQueryNormalize;
import cn.nine.pros.post.biz.mapper.AppFeedbackMapper;
import cn.nine.pros.post.biz.model.domain.AppFeedbackDomain;
import cn.nine.pros.post.biz.service.base.AppFeedbackService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.springframework.stereotype.Service;

@Service("baseAppFeedbackService")
public class AppFeedbackServiceImpl extends ServiceImpl<AppFeedbackMapper, AppFeedbackDomain>
        implements AppFeedbackService {

    @Override
    public Page<AppFeedbackDomain> pageForAdmin(PageQuery pageQuery) {
        return page(PageQueryNormalize.mpPage(pageQuery, PageQueryNormalize.ADMIN_MAX_SIZE), new LambdaQueryWrapper<AppFeedbackDomain>()
                .eq(AppFeedbackDomain::isDelFlag, false)
                .orderByDesc(AppFeedbackDomain::getCreatedAt));
    }
}
