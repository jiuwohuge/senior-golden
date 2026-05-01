package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.AnnouncementDomain;
import com.baomidou.mybatisplus.extension.service.IService;
import cn.nine.pros.post.client.model.db.AnnouncementDTO;

import java.util.List;

/**
 * 系统公告表 Service
 *
 * @author Administrator
 */
public interface AnnouncementService extends IService<AnnouncementDomain> {

    void upsert(AnnouncementDTO announcementDTO);

    AnnouncementDTO findById(Integer id);

    void delByIds(List<Integer> ids);

}