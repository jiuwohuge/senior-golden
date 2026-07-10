package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.MailOutboxDomain;
import com.baomidou.mybatisplus.extension.service.IService;

public interface MailOutboxService extends IService<MailOutboxDomain> {

    void enqueuePasswordReset(String toEmail, String localeTag, String code, int validMinutes);

    /** 邮箱验证绑定 / 登录挑战验证码邮件 */
    void enqueueEmailVerify(String toEmail, String localeTag, String code, int validMinutes);

    /** Called by scheduler: pull pending rows and attempt delivery. */
    void processPendingBatch();
}
