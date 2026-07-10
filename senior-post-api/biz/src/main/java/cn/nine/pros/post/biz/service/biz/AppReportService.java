package cn.nine.pros.post.biz.service.biz;

import cn.nine.pros.post.client.model.input.app.AppReportCreateInDto;

public interface AppReportService {

    void submit(long reporterUserId, AppReportCreateInDto body);
}
