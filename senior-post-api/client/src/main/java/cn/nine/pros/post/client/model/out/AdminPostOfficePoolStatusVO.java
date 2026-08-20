package cn.nine.pros.post.client.model.out;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 管理端冷启动池子与首页主推开关快照。
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "邮局池子状态")
public class AdminPostOfficePoolStatusVO {

    @Schema(description = "等待匹配的邮局信数量")
    private Long waitingMatchCount;

    @Schema(description = "可列出的活跃 App 用户数")
    private Long activeUserCount;

    @Schema(description = "当前是否视为可匹配（等待为 0 且有活跃用户）")
    private Boolean canMatchNow;

    @Schema(description = "首页主推：TIME_LETTER 或 POST_OFFICE")
    private String recommendedAction;

    @Schema(description = "sys_config 主键，保存开关时回传")
    private Integer recommendedActionConfigId;
}
