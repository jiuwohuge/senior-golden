package cn.nine.pros.post.client.api.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.db.AnnouncementDTO;
import cn.nine.pros.post.client.model.input.admin.AnnouncementInDto;
import cn.nine.pros.post.client.model.input.admin.AnnouncementQueryInDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@Tag(name = "管理后台-公告管理API")
public interface AdminAnnouncementApi {

    @Operation(summary = "公告列表")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/announcement/list")
    PageData<AnnouncementDTO> listAnnouncements(@RequestBody @Validated AnnouncementQueryInDto query);

    @Operation(summary = "创建公告")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/announcement")
    void createAnnouncement(@RequestBody @Validated AnnouncementInDto announcement);

    @Operation(summary = "更新公告")
    @PutMapping(AppServiceDefine.WEBAPI_PREFIX + "/announcement/{id}")
    void updateAnnouncement(@PathVariable("id") Integer id, @RequestBody @Validated AnnouncementInDto announcement);

    @Operation(summary = "删除公告")
    @DeleteMapping(AppServiceDefine.WEBAPI_PREFIX + "/announcement/{id}")
    void deleteAnnouncement(@PathVariable("id") Integer id);
}