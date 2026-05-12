package cn.nine.pros.post.client.api.app;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.input.app.AppDirectoryPageInDto;
import cn.nine.pros.post.client.model.out.DirectoryUserItemVO;
import cn.nine.pros.post.client.model.out.InterestTagOptionVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Tag(name = "App-通信名录")
@RequestMapping(AppServiceDefine.SERVER_PREFIX + "/directory")
public interface AppDirectoryApi {

    @Operation(summary = "用户名录分页（排除本人；可按国家/年龄/兴趣筛选）")
    @PostMapping("/users/paging")
    PageData<DirectoryUserItemVO> usersPaging(@RequestBody @Valid AppDirectoryPageInDto body);

    @Operation(summary = "通信名录用户公开资料（字段与分页项一致）")
    @GetMapping("/users/{userId}")
    DirectoryUserItemVO getDirectoryUser(@PathVariable("userId") Long userId);

    @Operation(summary = "兴趣标签名称列表（与名录筛选 interestNames / sys_tag.tag_name 一致）")
    @GetMapping("/interest-tags")
    List<String> listInterestTags(@RequestParam(value = "lang", required = false) String lang);

    @Operation(summary = "兴趣标签选项（id + 名称，资料 PATCH 用 id，名录筛选仍传 tag_name）")
    @GetMapping("/interest-tag-options")
    List<InterestTagOptionVO> listInterestTagOptions(@RequestParam(value = "lang", required = false) String lang);
}
