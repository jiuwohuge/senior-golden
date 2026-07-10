package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.MailOutboxDomain;
import com.baomidou.mybatisplus.extension.service.IService;

public interface MailOutboxService extends IService<MailOutboxDomain> {

    void enqueuePasswordReset(String toEmail, String localeTag, String code, int validMinutes);

    /** Called by scheduler: pull pending rows and attempt delivery. */
    void processPendingBatch();
}
