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

    /** 用户 + deviceUuid 未删除设备。 */
    UserDeviceDomain findActiveByUserIdAndDeviceUuid(long userId, String deviceUuid);

    /** 按 deviceUuid 取最近一条未删除设备（静默 guest 幂等）。 */
    UserDeviceDomain findLatestActiveByDeviceUuid(String deviceUuid);

    /**
     * 同一 deviceUuid 的全部设备行（含已软删设备，关闭 TableLogic）。
     * 用于 guest 找回本机账号；对应 user 仍由 {@code UserService.findById} 自动排除已删用户。
     */
    List<UserDeviceDomain> listByDeviceUuidIncludingDeleted(String deviceUuid);

    /** 软删该设备全部未删除记录（管理拉黑/解绑设备）。 */
    int deactivateActiveByDeviceUuid(String deviceUuid);


    java.util.List<UserDeviceDomain> listActiveByUserId(long userId);

    boolean blockByDeviceUuid(String deviceUuid, Long auditUserId);

    /** 注册或更新设备 push token。 */
    UserDeviceDomain upsertPushToken(Long userId, String deviceUuid, String platform, String token, boolean enabled);

}