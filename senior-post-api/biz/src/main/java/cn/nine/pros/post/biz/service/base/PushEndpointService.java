package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.PushEndpointDomain;
import com.baomidou.mybatisplus.extension.service.IService;

import java.util.List;

/**
 * 推送端点 Base Service。
 */
public interface PushEndpointService extends IService<PushEndpointDomain> {

    /**
     * 按用户 + 设备 upsert 端点（同事务内可与 user_device 一起更新）。
     */
    PushEndpointDomain upsertEndpoint(long userId, String deviceUuid, String platform,
                                      String pushToken, boolean enabled);

    /**
     * 用户下启用且未失效、未删除的端点。
     */
    List<PushEndpointDomain> listActiveEnabledByUserId(long userId);

    /**
     * 登出解绑：按用户 + 设备禁用并清空 token。
     */
    boolean unbindByUserAndDevice(long userId, String deviceUuid);

    /**
     * 标记 token 失效（FCM InvalidRegistration 等）。
     */
    boolean markInvalidated(long endpointId, String reason);
}
