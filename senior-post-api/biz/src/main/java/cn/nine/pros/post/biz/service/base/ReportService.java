package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.ReportDomain;
import com.baomidou.mybatisplus.extension.service.IService;
import cn.nine.pros.post.client.model.db.ReportDTO;

import java.util.List;

/**
 * 举报工单表 Service
 *
 * @author Administrator
 */
public interface ReportService extends IService<ReportDomain> {

    void upsert(ReportDTO reportDTO);

    ReportDTO findById(Long id);

    void delByIds(List<Long> ids);

    long countPendingByReporterTarget(long reporterUserId, String targetType, long targetId);

    long countPending();


    com.baomidou.mybatisplus.extension.plugins.pagination.Page<ReportDomain> pageForAdmin(
            cn.nine.commons.data.page.PageQuery pageQuery, Integer status, String targetType);

    boolean handleReport(long id, int status, String handleNote, Long handlerUserId);

}
