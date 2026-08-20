package cn.nine.pros.post.biz.mapper;

import cn.nine.pros.post.biz.model.domain.UserDeviceDomain;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;

import java.util.List;

/**
 * 用户设备记录表（用于风控/拉黑/防刷） Mapper
 *
 * @author Administrator
 */
@Mapper
public interface UserDeviceMapper extends BaseMapper<UserDeviceDomain> {

    /** 含已逻辑删除行；默认 BaseMapper 查询会被全局 TableLogic 过滤。 */
    @Select("SELECT * FROM bu_user_device WHERE device_uuid = #{deviceUuid} ORDER BY updated_at DESC")
    List<UserDeviceDomain> selectByDeviceUuidIncludingDeleted(@Param("deviceUuid") String deviceUuid);

}
