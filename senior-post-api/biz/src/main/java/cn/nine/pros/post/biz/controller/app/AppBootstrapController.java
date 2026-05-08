package cn.nine.pros.post.biz.controller.app;

import cn.nine.pros.post.biz.service.app.AppBootstrapService;
import cn.nine.pros.post.client.api.app.AppBootstrapApi;
import cn.nine.pros.post.client.model.out.AppBootstrapVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class AppBootstrapController implements AppBootstrapApi {

    private final AppBootstrapService appBootstrapService;

    @Override
    public AppBootstrapVO init(@RequestParam(value = "lang", required = false) String lang) {
        return appBootstrapService.init(lang);
    }
}
