package cn.nine.pros.post.biz.controller.app;

import cn.nine.pros.post.biz.service.app.AppBootstrapService;
import cn.nine.pros.post.biz.service.app.AppReleaseNoteService;
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
    public AppReleaseNoteVO releaseNote(@RequestParam("versionCode") int versionCode) {
        return appReleaseNoteService.findForApp(versionCode);
    }
}
