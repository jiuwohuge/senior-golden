package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.UserDeviceDomain;
import com.baomidou.mybatisplus.extension.service.IService;
import cn.nine.pros.post.client.model.db.UserDeviceDTO;

import java.util.List;

/**
 * 用户设备记录表（用于风控/拉黑/防刷） Service
 *
 * @author Administrator
 */
public interface UserDeviceService extends IService<UserDeviceDomain> {

    void upsert(UserDeviceDTO userDeviceDTO);

    UserDeviceDTO findById(Long id);

    void delByIds(List<Long> ids);

}