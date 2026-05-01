package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.VisitorRecordDomain;
import com.baomidou.mybatisplus.extension.service.IService;
import cn.nine.pros.post.client.model.db.VisitorRecordDTO;

import java.util.List;

/**
 * 访客记录表 Service
 *
 * @author Administrator
 */
public interface VisitorRecordService extends IService<VisitorRecordDomain> {

    void upsert(VisitorRecordDTO visitorRecordDTO);

    VisitorRecordDTO findById(Long id);

    void delByIds(List<Long> ids);

}