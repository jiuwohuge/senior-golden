package cn.nine.pros.post.biz.moderation.baidu;

import cn.nine.pros.post.biz.moderation.ImageModerationProvider;
import cn.nine.pros.post.biz.moderation.ModerationVerdict;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.stereotype.Component;

import com.baidu.aip.contentcensor.AipContentCensor;

@Component
@ConditionalOnMissingBean(AipContentCensor.class)
public class NoOpImageModerationProvider implements ImageModerationProvider {

    @Override
    public ImageModerationResult auditImage(byte[] imageBytes) {
        return ImageModerationResult.of(ModerationVerdict.SKIPPED, "baidu disabled");
    }
}
