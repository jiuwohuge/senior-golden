package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.UserDomain;
import com.baomidou.mybatisplus.extension.service.IService;
import cn.nine.pros.post.client.model.db.UserDTO;

import java.util.List;

/**
 * 用户主表 Service
 */
public interface UserService extends IService<UserDomain> {

    void upsert(UserDTO userDTO);

    UserDTO findById(Long id);

    void delByIds(List<Long> ids);

    /**
     * 按邮箱 identity 查询未删除用户；不存在返回 null。
     */
    UserDTO findByEmail(String email);

    /**
     * 与名录可列出 App 用户口径一致：del_flag=false, status=1, staff_role=0。
     */
    long countActiveAppUsers();

    /** 更新写作风格字段。 */
    void updateWritingStyle(long userId, String writingStyle);

    /** 设置用户 status。 */
    void updateStatus(long userId, int status);

    /** 标记邮箱已验证。 */
    void markEmailVerified(long userId);

    /** 登录成功：刷新 last_login_at，清除删除申请；可选补全 language。 */
    void markLoginSuccess(long userId, String languageIfEmpty);

    /** 申请注销。 */
    void requestDeletion(long userId);

    /** 完成注销（status=3）。 */
    void finalizeDeletion(long userId);

    /** 仅刷新 updated_at。 */
    void touchUpdatedAt(long userId);

    /**
     * 名录分页：正常用户、非后台、排除自己与互黑，支持筛选/排序。
     */
    com.baomidou.mybatisplus.extension.plugins.pagination.Page<UserDomain> pageDirectory(
            long viewerUserId,
            cn.nine.pros.post.client.model.input.app.AppDirectoryPageInDto body,
            cn.nine.commons.data.page.PageQuery pageQuery);

    com.baomidou.mybatisplus.extension.plugins.pagination.Page<UserDomain> pageForAdmin(
            cn.nine.commons.data.page.PageQuery pageQuery,
            String email, String nickname, Integer status, Integer avatarAuditStatus);

    /** 管理端更新 status（含 audit）。 */
    void adminUpdateStatus(long userId, int status, Long auditUserId);

    /** 管理端局部更新资料/头像。 */
    void adminUpdateProfile(long userId, Integer status, Integer birthYear, String nickname,
                            String countryCode, String bio, String avatarUrl, Integer avatarAuditStatus,
                            Long auditUserId);

    /** 管理端头像审核状态。 */
    void adminUpdateAvatarAudit(long userId, int avatarAuditStatus, Long auditUserId);

    /** 管理端 VIP 调试。 */
    void adminUpdateVipDebug(long userId, boolean isVip, java.time.LocalDateTime vipExpireAt,
                             boolean clearVipExpireAt, Long auditUserId);

    /**
     * 匹配候选：正常 App 用户（非后台），排除指定用户，按 id 倒序限量。
     */
    List<UserDomain> listActiveAppUsersExcluding(long excludeUserId, int limit);

}
