package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.support.PageQueryNormalize;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.nine.pros.post.biz.mapper.AnnouncementMapper;
import cn.nine.pros.post.biz.model.domain.AnnouncementDomain;
import cn.nine.pros.post.biz.model.mapstruct.AnnouncementMapstruct;
import cn.nine.pros.post.biz.service.base.AnnouncementService;
import cn.nine.pros.post.client.model.db.AnnouncementDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 系统公告表 ServiceImpl
 *
 * @author Administrator
 */
@Service
public class AnnouncementServiceImpl extends ServiceImpl<AnnouncementMapper, AnnouncementDomain>
        implements AnnouncementService {

    @Autowired
    private AnnouncementMapstruct announcementMapstruct;

    @Autowired
    private AppMessages appMessages;

    @Override
    public void upsert(AnnouncementDTO announcementDTO) {
        assertReleaseNoteContent(announcementDTO.getContent());
        assertVersionRange(announcementDTO.getMinVersionCode(), announcementDTO.getMaxVersionCode());
        Integer id = announcementDTO.getId();
        if (id == null) {
            AnnouncementDomain domain = announcementMapstruct.toDomain(announcementDTO);
            domain.initAudit(MyRequestContextHolder.userId());
            save(domain);
            return;
        }
        AnnouncementDomain domain = announcementMapstruct.toDomain(announcementDTO);
        domain.setId(id);
        domain.setUpdatedAt(LocalDateTime.now());
        domain.setUpdatedBy(MyRequestContextHolder.userId());
        updateById(domain);
    }

    @Override
    public AnnouncementDTO findById(Integer id) {
        return announcementMapstruct.toDTO(getById(id));
    }

    @Override
    public void delByIds(List<Integer> ids) {
        AnnouncementDomain announcementDomain = new AnnouncementDomain();
        announcementDomain.setDelFlag(true);
        announcementDomain.setUpdatedAt(LocalDateTime.now());
        update(announcementDomain, new LambdaQueryWrapper<AnnouncementDomain>()
                .in(AnnouncementDomain::getId, ids));
    }

    @Override
    public AnnouncementDomain findLatestVisibleForApp(int versionCode, LocalDateTime now) {
        int vc = Math.max(0, versionCode);
        return getOne(new LambdaQueryWrapper<AnnouncementDomain>()
                .eq(AnnouncementDomain::isDelFlag, false)
                .eq(AnnouncementDomain::getIsActive, true)
                .and(w -> w.isNull(AnnouncementDomain::getStartAt)
                        .or()
                        .le(AnnouncementDomain::getStartAt, now))
                .and(w -> w.isNull(AnnouncementDomain::getEndAt)
                        .or()
                        .ge(AnnouncementDomain::getEndAt, now))
                .and(w -> w.isNull(AnnouncementDomain::getMinVersionCode)
                        .or()
                        .le(AnnouncementDomain::getMinVersionCode, vc))
                .and(w -> w.isNull(AnnouncementDomain::getMaxVersionCode)
                        .or()
                        .ge(AnnouncementDomain::getMaxVersionCode, vc))
                .orderByDesc(AnnouncementDomain::getUpdatedAt)
                .last("LIMIT 1"));
    }

    private void assertReleaseNoteContent(String content) {
        if (content != null && content.contains("<")) {
            throw new BadRequestException(appMessages.get("admin.error.announcement.noHtml"));
        }
    }

    @Override
    public com.baomidou.mybatisplus.extension.plugins.pagination.Page<AnnouncementDomain> pageForAdmin(
            cn.nine.commons.data.page.PageQuery pageQuery) {
        return page(PageQueryNormalize.mpPage(pageQuery, PageQueryNormalize.ADMIN_MAX_SIZE),
                new LambdaQueryWrapper<AnnouncementDomain>()
                        .eq(AnnouncementDomain::isDelFlag, false)
                        .orderByDesc(AnnouncementDomain::getCreatedAt));
    }

    private void assertVersionRange(Integer min, Integer max) {
        if (min != null && max != null && min > max) {
            throw new BadRequestException(appMessages.get("admin.error.announcement.badVersionRange"));
        }
    }

}