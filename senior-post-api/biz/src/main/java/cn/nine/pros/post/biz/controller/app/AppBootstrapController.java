package cn.nine.pros.post.biz.controller.app;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.pros.post.biz.service.biz.AppBootstrapService;
import cn.nine.pros.post.biz.service.biz.AppReleaseNoteService;
import cn.nine.pros.post.client.api.app.AppBootstrapApi;
import cn.nine.pros.post.client.model.out.AppBootstrapVO;
import cn.nine.pros.post.client.model.out.AppReleaseNoteVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class AppBootstrapController implements AppBootstrapApi {

    private final AppBootstrapService appBootstrapService;
    private final AppReleaseNoteService appReleaseNoteService;

    @Override
    public AppBootstrapVO init(@RequestParam(value = "lang", required = false) String lang) {
        return appBootstrapService.init(lang);
    }

    @Override
    public AppReleaseNoteVO releaseNote(
            @RequestParam(value = "versionCode", required = false) Integer versionCode) {
        return appReleaseNoteService.findForApp(resolveClientVersionCode(versionCode));
    }

    /**
     * 优先使用请求头 versionCode（与 Dio 一致），避免 query 与 header 不一致导致公告筛不到。
     */
    private static int resolveClientVersionCode(Integer queryVersionCode) {
        Long header = MyRequestContextHolder.version();
        if (header != null && header > 0) {
            return header.intValue();
        }
        if (queryVersionCode != null && queryVersionCode >= 0) {
            return queryVersionCode;
        }
        return 0;
    }
}
