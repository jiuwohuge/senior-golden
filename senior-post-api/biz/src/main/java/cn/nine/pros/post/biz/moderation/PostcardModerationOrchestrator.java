package cn.nine.pros.post.biz.moderation;

import cn.nine.pros.post.biz.model.domain.PostcardDomain;
import cn.nine.pros.post.biz.service.base.PostcardService;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

@Slf4j
@Service
@RequiredArgsConstructor
public class PostcardModerationOrchestrator {

    private static final int REVIEW_PENDING = 0;
    private static final int REVIEW_APPROVED = 1;
    private static final int REVIEW_REJECTED = 2;

    private final PostcardService postcardService;
    private final ImageModerationProvider imageModerationProvider;
    private final TextModerationProvider textModerationProvider;
    private final OssObjectFetcher ossObjectFetcher;
    private final ModerationRuntimeConfigService moderationRuntimeConfigService;

    public void moderatePostcard(long postcardId) {
        PostcardDomain postcard = postcardService.getById(postcardId);
        if (postcard == null || postcard.isDelFlag()) {
            return;
        }
        Integer current = intVal(postcard.getReviewStatus());
        if (current != null && current == REVIEW_APPROVED) {
            return;
        }

        ModerationRuntimeConfig runtime = moderationRuntimeConfigService.get();
        List<String> imageRefs = collectImageRefs(postcard);
        boolean hasImages = !imageRefs.isEmpty();

        ModerationVerdict imageVerdict = ModerationVerdict.SKIPPED;
        if (hasImages) {
            if (runtime.isPostcardImageActive()) {
                imageVerdict = auditImages(imageRefs);
            }
        } else {
            imageVerdict = ModerationVerdict.PASS;
        }

        TextModerationProvider.TextModerationResult textResult =
                TextModerationProvider.TextModerationResult.of(ModerationVerdict.SKIPPED, "", "", "disabled");
        ModerationVerdict textVerdict = ModerationVerdict.SKIPPED;
        if (runtime.isPostcardTextActive()) {
            textResult = textModerationProvider.auditPostcardText(postcard.getContent());
            textVerdict = textResult.verdict();
        }

        int reviewStatus = decideReviewStatus(runtime, hasImages, imageVerdict, textVerdict);
        String note = buildNote(runtime, imageVerdict, textResult, imageRefs.size());

        LambdaUpdateWrapper<PostcardDomain> uw = new LambdaUpdateWrapper<PostcardDomain>()
                .eq(PostcardDomain::getId, postcardId)
                .set(PostcardDomain::getReviewStatus, reviewStatus)
                .set(PostcardDomain::getMachineReviewNote, note)
                .set(PostcardDomain::getMachineReviewedAt, LocalDateTime.now())
                .set(PostcardDomain::getUpdatedAt, LocalDateTime.now());
        postcardService.update(uw);
        log.info(
                "Postcard machine review done id={} status={} image={} text={}",
                postcardId,
                reviewStatus,
                imageVerdict,
                textVerdict);
    }

    private ModerationVerdict auditImages(List<String> imageRefs) {
        ModerationVerdict worst = ModerationVerdict.PASS;
        for (int i = 0; i < imageRefs.size(); i++) {
            String ref = imageRefs.get(i);
            var bytesOpt = ossObjectFetcher.tryFetchBytes(ref);
            if (bytesOpt.isEmpty()) {
                worst = maxSeverity(worst, ModerationVerdict.ERROR);
                continue;
            }
            ImageModerationProvider.ImageModerationResult result =
                    imageModerationProvider.auditImage(bytesOpt.get());
            worst = maxSeverity(worst, result.verdict());
            if (worst == ModerationVerdict.REJECT) {
                return worst;
            }
        }
        return worst;
    }

    private static int decideReviewStatus(
            ModerationRuntimeConfig runtime,
            boolean hasImages,
            ModerationVerdict imageVerdict,
            ModerationVerdict textVerdict) {
        if (imageVerdict == ModerationVerdict.REJECT || textVerdict == ModerationVerdict.REJECT) {
            return REVIEW_REJECTED;
        }
        if (!runtime.postcardImageEnabled() && !runtime.postcardTextEnabled()) {
            return REVIEW_PENDING;
        }
        boolean imageOk = !hasImages || (runtime.isPostcardImageActive() && imageVerdict == ModerationVerdict.PASS);
        boolean textOk = runtime.isPostcardTextActive() && textVerdict == ModerationVerdict.PASS;
        if (imageOk && textOk) {
            return REVIEW_APPROVED;
        }
        return REVIEW_PENDING;
    }

    private static String buildNote(
            ModerationRuntimeConfig runtime,
            ModerationVerdict imageVerdict,
            TextModerationProvider.TextModerationResult text,
            int imageCount) {
        StringBuilder sb = new StringBuilder();
        sb.append("imgSwitch=").append(runtime.postcardImageEnabled())
                .append(" txtSwitch=").append(runtime.postcardTextEnabled())
                .append("; image=").append(imageVerdict.name())
                .append(" count=").append(imageCount);
        if (text.verdict() != ModerationVerdict.PASS && text.verdict() != ModerationVerdict.SKIPPED) {
            sb.append("; text=").append(text.verdict().name());
            if (StringUtils.hasText(text.severity())) {
                sb.append(" severity=").append(text.severity());
            }
            if (StringUtils.hasText(text.reason())) {
                sb.append(" reason=").append(text.reason());
            }
        } else if (text.verdict() == ModerationVerdict.SKIPPED) {
            sb.append("; text=SKIPPED");
        }
        String s = sb.toString();
        return s.length() > 900 ? s.substring(0, 900) : s;
    }

    private static List<String> collectImageRefs(PostcardDomain postcard) {
        Set<String> refs = new LinkedHashSet<>();
        if (postcard.getImages() != null) {
            for (String u : postcard.getImages()) {
                if (StringUtils.hasText(u)) {
                    refs.add(u.trim());
                }
            }
        }
        if (StringUtils.hasText(postcard.getMainImageUrl())) {
            refs.add(postcard.getMainImageUrl().trim());
        }
        return new ArrayList<>(refs);
    }

    private static ModerationVerdict maxSeverity(ModerationVerdict current, ModerationVerdict next) {
        return severityRank(next) > severityRank(current) ? next : current;
    }

    private static int severityRank(ModerationVerdict v) {
        return switch (v) {
            case PASS -> 0;
            case SKIPPED -> 1;
            case REVIEW -> 2;
            case ERROR -> 3;
            case REJECT -> 4;
        };
    }

    private static Integer intVal(Object o) {
        if (o == null) {
            return null;
        }
        if (o instanceof Number n) {
            return n.intValue();
        }
        try {
            return Integer.parseInt(o.toString());
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
