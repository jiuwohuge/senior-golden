package cn.nine.pros.post.biz.service.base;

import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.model.domain.AppFeedbackDomain;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;

public interface AppFeedbackService extends IService<AppFeedbackDomain> {

    /** 管理端反馈分页（未删除，按创建时间倒序）。 */
    Page<AppFeedbackDomain> pageForAdmin(PageQuery pageQuery);
}
