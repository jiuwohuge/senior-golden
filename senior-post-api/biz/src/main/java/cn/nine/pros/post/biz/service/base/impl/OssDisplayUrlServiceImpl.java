package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.pros.post.biz.config.OssProperties;
import cn.nine.pros.post.biz.service.app.support.OssGetPresigner;
import cn.nine.pros.post.biz.service.app.support.OssObjectKeyResolver;
import cn.nine.pros.post.biz.service.base.OssDisplayUrlService;
import cn.nine.pros.post.biz.service.base.OssReadAuthorizationService;
import cn.nine.pros.post.client.model.out.OssGetSignItemVO;
import cn.nine.pros.post.client.model.out.PostcardAuthorVO;
import cn.nine.pros.post.client.model.out.PostcardDetailVO;
import cn.nine.pros.post.client.model.out.PostcardWallItemVO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class OssDisplayUrlServiceImpl implements OssDisplayUrlService {

    private final OssProperties ossProperties;
    private final OssObjectKeyResolver objectKeyResolver;
    private final OssReadAuthorizationService readAuthorizationService;
    private final OssGetPresigner ossGetPresigner;

    @Override
    public String signForViewer(long viewerUserId, String storedRef) {
        if (!StringUtils.hasText(storedRef) || !ossConfigured()) {
            return storedRef;
        }
        String t = storedRef.trim();
        Map<String, String> m = buildViewerSignedMap(viewerUserId, Set.of(t));
        return m.getOrDefault(t, t);
    }

    @Override
    public void applyPostcardWall(long viewerUserId, List<PostcardWallItemVO> rows) {
        if (rows == null || rows.isEmpty() || !ossConfigured()) {
            return;
        }
        Set<String> refs = new LinkedHashSet<>();
        for (PostcardWallItemVO r : rows) {
            collectImageRefs(r.getImageUrl(), r.getImageUrls(), refs);
            if (r.getAuthor() != null && StringUtils.hasText(r.getAuthor().getAvatarUrl())) {
                refs.add(r.getAuthor().getAvatarUrl().trim());
            }
        }
        Map<String, String> sig = buildViewerSignedMap(viewerUserId, refs);
        for (PostcardWallItemVO r : rows) {
            if (StringUtils.hasText(r.getImageUrl())) {
                r.setImageUrl(sig.getOrDefault(r.getImageUrl().trim(), r.getImageUrl()));
            }
            if (r.getImageUrls() != null && !r.getImageUrls().isEmpty()) {
                List<String> next = new ArrayList<>();
                for (String u : r.getImageUrls()) {
                    if (StringUtils.hasText(u)) {
                        String k = u.trim();
                        next.add(sig.getOrDefault(k, u));
                    } else {
                        next.add(u);
                    }
                }
                r.setImageUrls(next);
            }
            if (r.getAuthor() != null && StringUtils.hasText(r.getAuthor().getAvatarUrl())) {
                String a = r.getAuthor().getAvatarUrl().trim();
                r.getAuthor().setAvatarUrl(sig.getOrDefault(a, r.getAuthor().getAvatarUrl()));
            }
        }
    }

    @Override
    public void applyPostcardDetail(long viewerUserId, PostcardDetailVO detail) {
        if (detail == null || !ossConfigured()) {
            return;
        }
        Set<String> refs = new LinkedHashSet<>();
        collectImageRefs(detail.getImageUrl(), detail.getImageUrls(), refs);
        if (detail.getAuthor() != null && StringUtils.hasText(detail.getAuthor().getAvatarUrl())) {
            refs.add(detail.getAuthor().getAvatarUrl().trim());
        }
        Map<String, String> sig = buildViewerSignedMap(viewerUserId, refs);
        if (StringUtils.hasText(detail.getImageUrl())) {
            detail.setImageUrl(sig.getOrDefault(detail.getImageUrl().trim(), detail.getImageUrl()));
        }
        if (detail.getImageUrls() != null && !detail.getImageUrls().isEmpty()) {
            List<String> next = new ArrayList<>();
            for (String u : detail.getImageUrls()) {
                if (StringUtils.hasText(u)) {
                    String k = u.trim();
                    next.add(sig.getOrDefault(k, u));
                } else {
                    next.add(u);
                }
            }
            detail.setImageUrls(next);
        }
        if (detail.getAuthor() != null && StringUtils.hasText(detail.getAuthor().getAvatarUrl())) {
            String a = detail.getAuthor().getAvatarUrl().trim();
            detail.getAuthor().setAvatarUrl(sig.getOrDefault(a, detail.getAuthor().getAvatarUrl()));
        }
    }

    @Override
    public void applyAuthor(long viewerUserId, PostcardAuthorVO author) {
        if (author == null || !StringUtils.hasText(author.getAvatarUrl()) || !ossConfigured()) {
            return;
        }
        String a = author.getAvatarUrl().trim();
        author.setAvatarUrl(signForViewer(viewerUserId, a));
    }

    @Override
    public String signAvatarForViewer(long viewerUserId, String avatarStoredRef) {
        return signForViewer(viewerUserId, avatarStoredRef);
    }

    @Override
    public Map<String, String> signForStaffBatch(Set<String> storedRefs) {
        Map<String, String> out = new LinkedHashMap<>();
        if (storedRefs == null || storedRefs.isEmpty() || !ossConfigured()) {
            if (storedRefs != null) {
                for (String s : storedRefs) {
                    if (StringUtils.hasText(s)) {
                        out.put(s.trim(), s.trim());
                    }
                }
            }
            return out;
        }
        Map<String, String> storedToKey = new LinkedHashMap<>();
        for (String raw : storedRefs) {
            if (!StringUtils.hasText(raw)) {
                continue;
            }
            String s = raw.trim();
            Optional<String> key = objectKeyResolver.tryResolveObjectKey(s);
            if (key.isEmpty()) {
                out.put(s, s);
                continue;
            }
            readAuthorizationService.assertStaffCanRead(key.get());
            storedToKey.put(s, key.get());
        }
        if (storedToKey.isEmpty()) {
            return out;
        }
        List<String> uniqueKeys = new ArrayList<>(new LinkedHashSet<>(storedToKey.values()));
        List<OssGetSignItemVO> signed = ossGetPresigner.signGetUrls(uniqueKeys);
        Map<String, String> keyToUrl = new HashMap<>();
        for (OssGetSignItemVO it : signed) {
            keyToUrl.put(it.getObjectKey(), it.getSignedUrl());
        }
        for (var e : storedToKey.entrySet()) {
            String url = keyToUrl.get(e.getValue());
            out.put(e.getKey(), url != null ? url : e.getKey());
        }
        return out;
    }

    private Map<String, String> buildViewerSignedMap(long viewerUserId, Set<String> storedDistinct) {
        Map<String, String> out = new LinkedHashMap<>();
        if (storedDistinct == null || storedDistinct.isEmpty()) {
            return out;
        }
        if (!ossConfigured()) {
            for (String raw : storedDistinct) {
                if (StringUtils.hasText(raw)) {
                    String t = raw.trim();
                    out.put(t, t);
                }
            }
            return out;
        }
        Map<String, String> storedToKey = new LinkedHashMap<>();
        for (String raw : storedDistinct) {
            if (!StringUtils.hasText(raw)) {
                continue;
            }
            String s = raw.trim();
            Optional<String> key = objectKeyResolver.tryResolveObjectKey(s);
            if (key.isEmpty()) {
                out.put(s, s);
                continue;
            }
            readAuthorizationService.assertAppUserCanRead(viewerUserId, key.get(), s);
            storedToKey.put(s, key.get());
        }
        if (storedToKey.isEmpty()) {
            return out;
        }
        List<String> uniqueKeys = new ArrayList<>(new LinkedHashSet<>(storedToKey.values()));
        List<OssGetSignItemVO> signed = ossGetPresigner.signGetUrls(uniqueKeys);
        Map<String, String> keyToUrl = new HashMap<>();
        for (OssGetSignItemVO it : signed) {
            keyToUrl.put(it.getObjectKey(), it.getSignedUrl());
        }
        for (var e : storedToKey.entrySet()) {
            String url = keyToUrl.get(e.getValue());
            out.put(e.getKey(), url != null ? url : e.getKey());
        }
        return out;
    }

    private static void collectImageRefs(String imageUrl, List<String> imageUrls, Set<String> refs) {
        if (imageUrls != null) {
            for (String u : imageUrls) {
                if (StringUtils.hasText(u)) {
                    refs.add(u.trim());
                }
            }
        }
        if (StringUtils.hasText(imageUrl)) {
            refs.add(imageUrl.trim());
        }
    }

    private boolean ossConfigured() {
        return StringUtils.hasText(ossProperties.getEndpoint())
                && StringUtils.hasText(ossProperties.getAccessKeyId())
                && StringUtils.hasText(ossProperties.getAccessKeySecret())
                && StringUtils.hasText(ossProperties.getBucketName());
    }
}
