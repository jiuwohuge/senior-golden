package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.client.model.out.PostcardAuthorVO;
import cn.nine.pros.post.client.model.out.PostcardDetailVO;
import cn.nine.pros.post.client.model.out.PostcardWallItemVO;

import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * 将库内存储的 OSS 引用替换为短时 GET 预签名 URL（App 出站 / 管理端审核）。
 */
public interface OssDisplayUrlService {

    String signForViewer(long viewerUserId, String storedRef);

    void applyPostcardWall(long viewerUserId, List<PostcardWallItemVO> rows);

    void applyPostcardDetail(long viewerUserId, PostcardDetailVO detail);

    void applyAuthor(long viewerUserId, PostcardAuthorVO author);

    String signAvatarForViewer(long viewerUserId, String avatarStoredRef);

    Map<String, String> signForStaffBatch(Set<String> storedRefs);

    default Map<String, String> signForStaffBatch(List<String> storedRefs) {
        if (storedRefs == null) {
            return Map.of();
        }
        return signForStaffBatch(new LinkedHashSet<>(storedRefs));
    }
}
