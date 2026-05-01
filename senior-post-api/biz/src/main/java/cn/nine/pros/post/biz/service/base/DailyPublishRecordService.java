package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.DailyPublishRecordDomain;
import com.baomidou.mybatisplus.extension.service.IService;
import cn.nine.pros.post.client.model.db.DailyPublishRecordDTO;

import java.util.List;

/**
 * 每日发布记录表 Service
 *
 * @author Administrator
 */
public interface DailyPublishRecordService extends IService<DailyPublishRecordDomain> {

    void upsert(DailyPublishRecordDTO dailyPublishRecordDTO);

    DailyPublishRecordDTO findById(Long id);

    void delByIds(List<Long> ids);

}