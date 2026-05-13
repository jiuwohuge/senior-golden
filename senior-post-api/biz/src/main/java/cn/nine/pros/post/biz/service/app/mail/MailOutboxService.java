package cn.nine.pros.post.biz.service.app.mail;

public interface MailOutboxService {

    void enqueuePasswordReset(String toEmail, String localeTag, String code, int validMinutes);

    /**
     * 由定时任务调用：拉取待发送记录并尝试投递。
     */
    void processPendingBatch();
}
