package cn.nine.pros.post.client.api.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.db.AnnouncementDTO;
import cn.nine.pros.post.client.model.input.admin.AnnouncementInDto;
import cn.nine.pros.post.client.model.input.admin.AnnouncementQueryInDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

@Tag(name = "管理后台-公告")
public interface AdminAnnouncementApi {

    @Operation(summary = "公告分页")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/announcement/paging")
    PageData<AnnouncementDTO> paging(@RequestBody @Valid AnnouncementQueryInDto body);

    @Operation(summary = "保存公告")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/announcement/save")
    void save(@RequestBody @Valid AnnouncementInDto body);

    @Operation(summary = "删除公告")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/announcement/{id}/delete")
    void delete(@PathVariable("id") Integer id);
}
