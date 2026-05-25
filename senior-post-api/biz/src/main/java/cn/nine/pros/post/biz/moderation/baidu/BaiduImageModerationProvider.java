package cn.nine.pros.post.biz.moderation.baidu;

import cn.nine.pros.post.biz.moderation.ImageModerationProvider;
import cn.nine.pros.post.biz.moderation.ModerationVerdict;
import com.baidu.aip.contentcensor.AipContentCensor;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONObject;
import org.springframework.boot.autoconfigure.condition.ConditionalOnBean;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Component
@RequiredArgsConstructor
@ConditionalOnBean(AipContentCensor.class)
public class BaiduImageModerationProvider implements ImageModerationProvider {

    private final AipContentCensor aipContentCensor;
    private final ObjectMapper objectMapper;

    @Override
    public ImageModerationResult auditImage(byte[] imageBytes) {
        if (imageBytes == null || imageBytes.length == 0) {
            return ImageModerationResult.of(ModerationVerdict.ERROR, "empty image");
        }
        try {
            JSONObject raw = aipContentCensor.imageCensorUserDefined(imageBytes, null);
            if (raw == null) {
                return ImageModerationResult.of(ModerationVerdict.ERROR, "null response");
            }
            if (log.isDebugEnabled()) {
                log.debug("Baidu image censor response: {}", raw);
            }
            BaiduImageCensorResponse parsed = objectMapper.readValue(raw.toString(), BaiduImageCensorResponse.class);
            return mapVerdict(parsed);
        } catch (Exception e) {
            log.warn("Baidu image moderation failed: {}", e.getMessage());
            return ImageModerationResult.of(ModerationVerdict.ERROR, e.getMessage());
        }
    }

    private ImageModerationResult mapVerdict(BaiduImageCensorResponse json) {
        if (json == null) {
            return ImageModerationResult.of(ModerationVerdict.ERROR, "empty parsed body");
        }
        if (json.getErrorCode() != null && json.getErrorCode() != 0) {
            return ImageModerationResult.of(
                    ModerationVerdict.ERROR, "baidu:" + json.getErrorCode() + " " + json.getErrorMsg());
        }
        Integer conclusionType = json.getConclusionType();
        if (conclusionType == null) {
            return ImageModerationResult.of(ModerationVerdict.ERROR, "missing conclusionType");
        }
        if (conclusionType == 1) {
            return ImageModerationResult.of(ModerationVerdict.PASS, "");
        }
        if (conclusionType != 2 && conclusionType != 3) {
            return ImageModerationResult.of(ModerationVerdict.ERROR, "conclusionType=" + conclusionType);
        }
        List<BaiduImageCensorResponse.DataItem> items = json.getData();
        if (items == null || items.isEmpty()) {
            return ImageModerationResult.of(ModerationVerdict.PASS, "");
        }
        List<BaiduImageCensorResponse.DataItem> pornItems =
                items.stream().filter(e -> e.getType() != null && e.getType() == 1).toList();
        if (pornItems.isEmpty()) {
            String other = items.stream()
                    .map(BaiduImageCensorResponse.DataItem::getMsg)
                    .filter(m -> m != null && !m.isBlank())
                    .collect(Collectors.joining(","));
            return ImageModerationResult.of(ModerationVerdict.REVIEW, other);
        }
        String detail = pornItems.stream()
                .map(BaiduImageCensorResponse.DataItem::getMsg)
                .filter(m -> m != null && !m.isBlank())
                .collect(Collectors.joining(","));
        ModerationVerdict verdict = conclusionType == 2 ? ModerationVerdict.REJECT : ModerationVerdict.REVIEW;
        return ImageModerationResult.of(verdict, detail);
    }
}
