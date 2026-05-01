package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.model.domain.AnnouncementDomain;
import cn.nine.pros.post.biz.model.mapstruct.AnnouncementMapstruct;
import cn.nine.pros.post.biz.service.base.AnnouncementService;
import cn.nine.pros.post.client.api.admin.AdminAnnouncementApi;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.db.AnnouncementDTO;
import cn.nine.pros.post.client.model.input.admin.AnnouncementInDto;
import cn.nine.pros.post.client.model.input.admin.AnnouncementQueryInDto;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequiredArgsConstructor
@Tag(name = "管理后台-公告管理API")
public class AdminAnnouncementController implements AdminAnnouncementApi {

    private final AnnouncementService announcementService;
    private final AnnouncementMapstruct announcementMapstruct;

    @Override
    @Operation(summary = "公告列表")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/announcement/list")
    public PageData<AnnouncementDTO> listAnnouncements(@RequestBody AnnouncementQueryInDto query) {
        PageQuery pageQuery = query.getPage() != null ? query.getPage() : new PageQuery();
        int pageNum = pageQuery.getPage() != null ? pageQuery.getPage() : 1;
        int pageSize = pageQuery.getSize() != null ? pageQuery.getSize() : 10;

        LambdaQueryWrapper<AnnouncementDomain> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(AnnouncementDomain::getDelFlag, false);
        wrapper.orderByDesc(AnnouncementDomain::getCreatedAt);

        Page<AnnouncementDomain> page = announcementService.page(new Page<>(pageNum, pageSize), wrapper);
        List<AnnouncementDTO> records = page.getRecords().stream().map(announcementMapstruct::toDTO).toList();

        PageData<AnnouncementDTO> result = new PageData<>();
        result.setRecords(records);
        result.setTotal(page.getTotal());
        result.setPages(page.getPages());
        result.setPage(page.getCurrent());
        result.setSize(page.getSize());
        return result;
    }

    @Override
    @Operation(summary = "创建公告")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/announcement")
    @Transactional
    public void createAnnouncement(@RequestBody AnnouncementInDto announcement) {
        AnnouncementDomain domain = new AnnouncementDomain();
        domain.setTitle(announcement.getTitle());
        domain.setTitleJson(announcement.getTitleJson());
        domain.setContent(announcement.getContent());
        domain.setContentJson(announcement.getContentJson());
        domain.setStartAt(announcement.getStartAt());
        domain.setEndAt(announcement.getEndAt());
        domain.setIsActive(announcement.getIsActive());
        domain.initAudit(MyRequestContextHolder.userId());
        announcementService.save(domain);
    }

    @Override
    @Operation(summary = "更新公告")
    @PutMapping(AppServiceDefine.WEBAPI_PREFIX + "/announcement/{id}")
    @Transactional
    public void updateAnnouncement(@PathVariable("id") Integer id, @RequestBody AnnouncementInDto announcement) {
        AnnouncementDomain domain = announcementService.getById(id);
        if (domain == null) {
            throw new cn.nine.commons.basic.exception.BadRequestException("公告不存在");
        }
        domain.setTitle(announcement.getTitle());
        domain.setTitleJson(announcement.getTitleJson());
        domain.setContent(announcement.getContent());
        domain.setContentJson(announcement.getContentJson());
        domain.setStartAt(announcement.getStartAt());
        domain.setEndAt(announcement.getEndAt());
        domain.setIsActive(announcement.getIsActive());
        domain.updateAudit(MyRequestContextHolder.userId());
        announcementService.updateById(domain);
    }

    @Override
    @Operation(summary = "删除公告")
    @DeleteMapping(AppServiceDefine.WEBAPI_PREFIX + "/announcement/{id}")
    @Transactional
    public void deleteAnnouncement(@PathVariable("id") Integer id) {
        AnnouncementDomain domain = announcementService.getById(id);
        if (domain == null) {
            throw new cn.nine.commons.basic.exception.BadRequestException("公告不存在");
        }
        domain.setDelFlag(true);
        announcementService.updateById(domain);
    }
}