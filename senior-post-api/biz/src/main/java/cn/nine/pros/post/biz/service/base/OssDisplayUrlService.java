package cn.nine.pros.post.biz.service.base;

import java.util.Map;
import java.util.Set;

public interface OssDisplayUrlService {

    String signAvatarForViewer(long viewerUserId, String avatarStoredRef);

    /**
     * 空引用返回 null；否则 trim 后按查看者签名。
     */
    String signAvatarRefOrNull(long viewerUserId, String avatarStoredRef);

    Map<String, String> signForStaffBatch(Set<String> storedRefs);
}
