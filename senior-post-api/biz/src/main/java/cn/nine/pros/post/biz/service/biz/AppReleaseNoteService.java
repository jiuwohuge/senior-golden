package cn.nine.pros.post.biz.service.biz;

import cn.nine.pros.post.biz.model.domain.AnnouncementDomain;
import cn.nine.pros.post.biz.service.base.AnnouncementService;
import cn.nine.pros.post.client.model.out.AppReleaseNoteVO;
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
        AnnouncementDomain row = announcementService.findLatestVisibleForApp(versionCode, LocalDateTime.now());
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
