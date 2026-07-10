package cn.nine.pros.post.biz.service.base;

import java.util.Map;
import java.util.Set;

public interface OssDisplayUrlService {

    String signAvatarForViewer(long viewerUserId, String avatarStoredRef);

    Map<String, String> signForStaffBatch(Set<String> storedRefs);
}
