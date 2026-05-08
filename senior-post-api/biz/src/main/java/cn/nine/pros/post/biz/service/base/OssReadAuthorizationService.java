package cn.nine.pros.post.biz.service.base;

import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.pros.post.biz.config.OssProperties;
import cn.nine.pros.post.biz.mapper.LetterMapper;
import cn.nine.pros.post.biz.mapper.PostcardMapper;
import cn.nine.pros.post.biz.service.app.support.OssReadableKeyValidator;
import cn.nine.pros.post.client.model.db.UserDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;

/**
 * 私有 OSS 读签名前的业务鉴权。
 */
@Service
@RequiredArgsConstructor
public class OssReadAuthorizationService {

    private final OssProperties ossProperties;
    private final PostcardMapper postcardMapper;
    private final LetterMapper letterMapper;
    private final UserService userService;

    public void assertAppUserCanRead(long viewerUserId, String normalizedObjectKey, String originalRef) {
        String prefix = ossProperties.getKeyPrefix().replaceAll("^/+|/+$", "");
        OssReadableKeyValidator.ParsedOssKey p =
                OssReadableKeyValidator.parseNormalizedKey(prefix, normalizedObjectKey);
        List<String> variants = buildLookupVariants(originalRef, normalizedObjectKey);
        switch (p.sceneLower()) {
            case "postcard" -> {
                if (postcardMapper.countVisibleReferencingImage(viewerUserId, variants) < 1) {
                    throw new BadRequestException("无权读取该图片");
                }
            }
            case "avatar" -> {
                UserDTO owner = userService.findById(p.ownerUserId());
                if (owner == null) {
                    throw new BadRequestException("无权读取该图片");
                }
                if (owner.getStatus() == null || !Integer.valueOf(1).equals(convertStatus(owner.getStatus()))) {
                    throw new BadRequestException("无权读取该图片");
                }
                // 已登录用户可读「正常用户」头像（墙/名录展示）；objectKey 仍难枚举。
            }
            case "letter" -> {
                if (letterMapper.countPeerLetterReferencingContent(viewerUserId, p.ownerUserId(), variants) < 1) {
                    throw new BadRequestException("无权读取该图片");
                }
            }
            default -> throw new BadRequestException("无权读取该图片");
        }
    }

    /** 管理端：仅校验 key 形态（已在换签前由校验器保证），不做业务绑定。 */
    public void assertStaffCanRead(String normalizedObjectKey) {
        String prefix = ossProperties.getKeyPrefix().replaceAll("^/+|/+$", "");
        OssReadableKeyValidator.parseNormalizedKey(prefix, normalizedObjectKey);
    }

    private List<String> buildLookupVariants(String originalRef, String normalizedKey) {
        Set<String> set = new LinkedHashSet<>();
        if (StringUtils.hasText(originalRef)) {
            set.add(originalRef.trim());
        }
        set.add(normalizedKey);
        if (StringUtils.hasText(ossProperties.getPublicReadBaseUrl())) {
            String base = ossProperties.getPublicReadBaseUrl().trim().replaceAll("/+$", "");
            String scheme = base.toLowerCase(Locale.ROOT).startsWith("http")
                    ? base
                    : "https://" + base;
            set.add(scheme + "/" + normalizedKey);
        }
        return new ArrayList<>(set);
    }

    private static Integer convertStatus(Object status) {
        if (status instanceof Number n) {
            return n.intValue();
        }
        if (status instanceof String s) {
            return Integer.valueOf(s);
        }
        return null;
    }
}
