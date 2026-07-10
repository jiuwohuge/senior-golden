package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.pros.post.biz.config.OssProperties;
import cn.nine.pros.post.biz.service.biz.support.OssGetPresigner;
import cn.nine.pros.post.biz.service.biz.support.OssObjectKeyResolver;
import cn.nine.pros.post.biz.service.base.OssDisplayUrlService;
import cn.nine.pros.post.biz.service.base.OssReadAuthorizationService;
import cn.nine.pros.post.client.model.out.OssGetSignItemVO;
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

    private String signForViewer(long viewerUserId, String storedRef) {
        if (!StringUtils.hasText(storedRef) || !ossConfigured()) {
            return storedRef;
        }
        String t = storedRef.trim();
        Map<String, String> m = buildViewerSignedMap(viewerUserId, Set.of(t));
        return m.getOrDefault(t, t);
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


    private boolean ossConfigured() {
        return StringUtils.hasText(ossProperties.getEndpoint())
                && StringUtils.hasText(ossProperties.getAccessKeyId())
                && StringUtils.hasText(ossProperties.getAccessKeySecret())
                && StringUtils.hasText(ossProperties.getBucketName());
    }
}
