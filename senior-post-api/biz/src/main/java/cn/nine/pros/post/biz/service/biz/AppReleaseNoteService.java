package cn.nine.pros.post.biz.service.biz;

import cn.nine.pros.post.biz.model.domain.AnnouncementDomain;
import cn.nine.pros.post.biz.service.base.AnnouncementService;
import cn.nine.pros.post.client.model.out.AppReleaseNoteVO;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class AppReleaseNoteService {

    private final AnnouncementService announcementService;

    /**
     * 取当前对客户端可见的一条版本公告（按 {@code updated_at} 最新）。
     */
    public AppReleaseNoteVO findForApp(int versionCode) {
        int vc = Math.max(0, versionCode);
        LocalDateTime now = LocalDateTime.now();
        AnnouncementDomain row = announcementService.getOne(
                new LambdaQueryWrapper<AnnouncementDomain>()
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
        if (row == null) {
            return null;
        }
        return AppReleaseNoteVO.builder()
                .id(row.getId())
                .title(row.getTitle())
                .versionLabel(row.getVersionLabel())
                .releaseNotes(row.getContent())
                .build();
    }
}
