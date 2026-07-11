package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.MailOutboxDomain;
import com.baomidou.mybatisplus.extension.service.IService;

import java.time.LocalDateTime;

public interface MailOutboxService extends IService<MailOutboxDomain> {

    void enqueuePasswordReset(String toEmail, String localeTag, String code, int validMinutes);

    /** 邮箱验证绑定 / 登录挑战验证码邮件 */
    void enqueueEmailVerify(String toEmail, String localeTag, String code, int validMinutes);

    /** Called by scheduler: pull pending rows and attempt delivery. */
    void processPendingBatch();

    /** 管理端分页。 */
    com.baomidou.mybatisplus.extension.plugins.pagination.Page<MailOutboxDomain> pageForAdmin(
            cn.nine.commons.data.page.PageQuery pageQuery,
            String toEmail, String mailType, String status,
            LocalDateTime createdFrom, LocalDateTime createdTo, String keyword);

    /** 按主键查详情；不存在返回 null。 */
    MailOutboxDomain findById(Long id);

    /**
     * 失败重试：重置 status=pending、清空 lastError、nextRetryAt=now。
     *
     * @return 是否更新成功
     */
    boolean retryFailed(long id);

    /** 按状态计数。 */
    long countByStatus(String status);
}
