package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.model.domain.AnnouncementDomain;
import cn.nine.pros.post.biz.model.mapstruct.AnnouncementMapstruct;
import cn.nine.pros.post.biz.service.base.AnnouncementService;
import cn.nine.pros.post.client.api.admin.AdminAnnouncementApi;
import cn.nine.pros.post.client.model.db.AnnouncementDTO;
import cn.nine.pros.post.client.model.input.admin.AnnouncementInDto;
import cn.nine.pros.post.client.model.input.admin.AnnouncementQueryInDto;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequiredArgsConstructor
public class AdminAnnouncementController implements AdminAnnouncementApi {

    private final AnnouncementService announcementService;
    private final AnnouncementMapstruct announcementMapstruct;

    @Override
    public PageData<AnnouncementDTO> paging(AnnouncementQueryInDto body) {
        PageQuery pageQuery = AdminPageHelper.normalize(body.getPage());
        LambdaQueryWrapper<AnnouncementDomain> qw = new LambdaQueryWrapper<AnnouncementDomain>()
                .eq(AnnouncementDomain::isDelFlag, false)
                .orderByDesc(AnnouncementDomain::getCreatedAt);
        Page<AnnouncementDomain> p = announcementService.page(AdminPageHelper.mpPage(pageQuery), qw);
        List<AnnouncementDTO> list = p.getRecords().stream().map(announcementMapstruct::toDTO).collect(Collectors.toList());
        return AdminPageHelper.pageData(pageQuery, p, list);
    }

    @Override
    public void save(AnnouncementInDto body) {
        AnnouncementDTO dto = new AnnouncementDTO();
        dto.setId(body.getId());
        dto.setTitle(body.getTitle());
        dto.setTitleJson(body.getTitleJson());
        dto.setContent(body.getContent());
        dto.setContentJson(body.getContentJson());
        dto.setStartAt(body.getStartAt());
        dto.setEndAt(body.getEndAt());
        dto.setIsActive(body.getIsActive());
        announcementService.upsert(dto);
    }

    @Override
    public void delete(Integer id) {
        announcementService.delByIds(java.util.List.of(id));
    }
}
