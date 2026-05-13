package cn.nine.pros.post.client.model.out;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
@Schema(description = "App 版本公告（结构化，非强更）")
public class AppReleaseNoteVO {

    @Schema(description = "公告 ID")
    private Integer id;

    @Schema(description = "标题")
    private String title;

    @Schema(description = "版本号（展示）")
    private String versionLabel;

    @Schema(description = "更新说明（纯文本多行）")
    private String releaseNotes;
}
