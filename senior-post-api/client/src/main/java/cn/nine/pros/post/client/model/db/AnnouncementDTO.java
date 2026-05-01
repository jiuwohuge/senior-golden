package cn.nine.pros.post.client.model.db;

import cn.nine.commons.data.dto.AbstractAuditableDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

/**
 * 系统公告表 DTO
 *
 * @author Administrator
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
public class AnnouncementDTO extends AbstractAuditableDTO {

    private static final long serialVersionUID = 1L;

    /**
     * 公告ID
     */
    @Schema(description = "公告ID")
    private Integer id;
    /**
     * 标题（单语言备用）
     */
    @Schema(description = "标题（单语言备用）")
    private String title;
    /**
     * 标题多语言JSON {"en":"...", "zh":"..."}
     */
    @Schema(description = "标题多语言JSON {\"en\":\"...\",\"zh\":\"...\"}")
    private Object titleJson;
    /**
     * 内容（单语言备用）
     */
    @Schema(description = "内容（单语言备用）")
    private String content;
    /**
     * 内容多语言JSON {"en":"...", "zh":"..."}
     */
    @Schema(description = "内容多语言JSON {\"en\":\"...\",\"zh\":\"...\"}")
    private Object contentJson;
    /**
     * 生效开始时间
     */
    @Schema(description = "生效开始时间")
    private Object startAt;
    /**
     * 生效结束时间
     */
    @Schema(description = "生效结束时间")
    private Object endAt;
    /**
     * 是否激活
     */
    @Schema(description = "是否激活")
    private Boolean isActive;

}