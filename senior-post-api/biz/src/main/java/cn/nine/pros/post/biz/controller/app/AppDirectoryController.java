package cn.nine.pros.post.biz.controller.app;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.biz.service.app.AppDirectoryService;
import cn.nine.pros.post.client.api.app.AppDirectoryApi;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.input.app.AppDirectoryPageInDto;
import cn.nine.pros.post.client.model.out.DirectoryUserItemVO;
import cn.nine.pros.post.client.model.out.InterestTagOptionVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

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

    @Override
    @Operation(summary = "通信名录用户公开资料（字段与分页项一致）")
    @GetMapping(AppServiceDefine.SERVER_PREFIX + "/directory/users/{userId}")
    public DirectoryUserItemVO getDirectoryUser(@PathVariable("userId") Long userId) {
        Long uid = MyRequestContextHolder.userId();
        if (uid == null) {
            throw new BadRequestException("未登录");
        }
        return appDirectoryService.getDirectoryUser(uid, userId);
    }

    @Override
    @Operation(summary = "兴趣标签名称列表（与名录筛选 interestNames / sys_tag.tag_name 一致）")
    @GetMapping(AppServiceDefine.SERVER_PREFIX + "/directory/interest-tags")
    public List<String> listInterestTags(@RequestParam(value = "lang", required = false) String lang) {
        Long uid = MyRequestContextHolder.userId();
        if (uid == null) {
            throw new BadRequestException("未登录");
        }
        return appDirectoryService.listInterestTagNames(lang);
    }

    @Override
    @Operation(summary = "兴趣标签选项（id + 名称，资料 PATCH 用 id，名录筛选仍传 tag_name）")
    @GetMapping(AppServiceDefine.SERVER_PREFIX + "/directory/interest-tag-options")
    public List<InterestTagOptionVO> listInterestTagOptions(@RequestParam(value = "lang", required = false) String lang) {
        Long uid = MyRequestContextHolder.userId();
        if (uid == null) {
            throw new BadRequestException("未登录");
        }
        return appDirectoryService.listInterestTagOptions(lang);
    }
}
