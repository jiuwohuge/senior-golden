package cn.nine.pros.post.biz.controller;

import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.commons.feign.bridge.core.model.FeignPage;
import cn.nine.pros.post.biz.service.clients.ExampleFeignClient;
import cn.nine.pros.post.client.api.ExampleApi;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.db.ExampleDTO;
import cn.nine.pros.post.client.model.input.ExamplePageInDto;
import cn.nine.pros.post.client.model.out.ExampleVO;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
@RequestMapping(AppServiceDefine.SERVER_PREFIX + "/example")
public class ExampleController implements ExampleApi {

    @Autowired
    private ExampleFeignClient exampleFeignClient;

    @Override
    public ExampleDTO findExample(@RequestParam("id") Long id) {
        log.info("findExample id:{}", id);
        return exampleFeignClient.feignQueryById(id);
    }

    @Override
    public PageData<ExampleDTO> pagingExample(@RequestBody @Validated ExamplePageInDto param) {
        FeignPage feignPage = new FeignPage();
        feignPage.setPage(param.getPage());
        return exampleFeignClient.feignPage(feignPage);
    }


}
