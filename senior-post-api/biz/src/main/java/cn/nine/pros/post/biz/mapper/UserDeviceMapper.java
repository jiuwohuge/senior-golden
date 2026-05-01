package cn.nine.pros.post.biz.mapper;

import cn.nine.pros.post.biz.model.domain.UserDeviceDomain;
import org.apache.ibatis.annotations.Mapper;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;

/**
 * 用户设备记录表（用于风控/拉黑/防刷） Mapper
 *
 * @author Administrator
 */
@Mapper
public interface UserDeviceMapper extends BaseMapper<UserDeviceDomain> {

}
