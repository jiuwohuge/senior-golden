package cn.nine.pros.post.biz.controller.app;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.biz.service.app.AppDirectoryService;
import cn.nine.pros.post.client.api.app.AppDirectoryApi;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.input.app.AppDirectoryPageInDto;
import cn.nine.pros.post.client.model.out.DirectoryUserItemVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@Tag(name = "App-通信名录")
public class AppDirectoryController implements AppDirectoryApi {

    private final AppDirectoryService appDirectoryService;

    @Override
    @Operation(summary = "用户名录分页（排除本人；可按国家/年龄/兴趣筛选）")
    @PostMapping(AppServiceDefine.SERVER_PREFIX + "/directory/users/paging")
    public PageData<DirectoryUserItemVO> usersPaging(@RequestBody @Valid AppDirectoryPageInDto body) {
        Long uid = MyRequestContextHolder.userId();
        if (uid == null) {
            throw new BadRequestException("未登录");
        }
        return appDirectoryService.pageUsers(uid, body);
    }
}
