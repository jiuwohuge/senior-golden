package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.biz.service.biz.admin.AdminAnnouncementBizService;
import cn.nine.pros.post.client.api.admin.AdminAnnouncementApi;
import cn.nine.pros.post.client.model.db.AnnouncementDTO;
import cn.nine.pros.post.client.model.input.admin.AnnouncementInDto;
import cn.nine.pros.post.client.model.input.admin.AnnouncementQueryInDto;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class AdminAnnouncementController implements AdminAnnouncementApi {

    private final AdminAnnouncementBizService adminAnnouncementBizService;

    @Override
    public PageData<AnnouncementDTO> paging(AnnouncementQueryInDto body) {
        return adminAnnouncementBizService.paging(body);
    }

    @Override
    public void save(AnnouncementInDto body) {
        adminAnnouncementBizService.save(body);
    }

    @Override
    public void delete(Integer id) {
        adminAnnouncementBizService.delete(id);
    }
}
