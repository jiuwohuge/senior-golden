package cn.nine.pros.post.biz.service.biz.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.controller.admin.AdminPageHelper;
import cn.nine.pros.post.biz.model.domain.AnnouncementDomain;
import cn.nine.pros.post.biz.model.mapstruct.AnnouncementMapstruct;
import cn.nine.pros.post.biz.service.base.AnnouncementService;
import cn.nine.pros.post.client.model.db.AnnouncementDTO;
import cn.nine.pros.post.client.model.input.admin.AnnouncementInDto;
import cn.nine.pros.post.client.model.input.admin.AnnouncementQueryInDto;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 管理端公告 CRUD。
 */
@Service
@RequiredArgsConstructor
public class AdminAnnouncementBizService {

    private final AnnouncementService announcementService;
    private final AnnouncementMapstruct announcementMapstruct;

    /**
     * 分页查询公告列表。
     */
    public PageData<AnnouncementDTO> paging(AnnouncementQueryInDto body) {
        PageQuery pageQuery = AdminPageHelper.normalize(body.getPage());
        Page<AnnouncementDomain> p = announcementService.pageForAdmin(pageQuery);
        List<AnnouncementDTO> list = p.getRecords().stream().map(announcementMapstruct::toDTO).collect(Collectors.toList());
        return AdminPageHelper.pageData(pageQuery, p, list);
    }

    /**
     * 新增或更新公告（含多语言与版本范围）。
     */
    public void save(AnnouncementInDto body) {
        AnnouncementDTO dto = new AnnouncementDTO();
        dto.setId(body.getId());
        dto.setTitle(body.getTitle());
        dto.setTitleJson(body.getTitleJson());
        dto.setContent(body.getContent());
        dto.setContentJson(body.getContentJson());
        dto.setStartAt(body.getStartAt());
        dto.setEndAt(body.getEndAt());
        dto.setIsActive(body.getIsActive() == null || Boolean.TRUE.equals(body.getIsActive()));
        dto.setVersionLabel(body.getVersionLabel());
        dto.setMinVersionCode(body.getMinVersionCode());
        dto.setMaxVersionCode(body.getMaxVersionCode());
        announcementService.upsert(dto);
    }

    /**
     * 按主键删除公告。
     */
    public void delete(Integer id) {
        announcementService.delByIds(List.of(id));
    }
}
