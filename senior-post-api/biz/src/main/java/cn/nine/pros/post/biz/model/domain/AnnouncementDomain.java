package cn.nine.pros.post.biz.model.domain;

import cn.nine.commons.data.domain.AbstractAuditableDomain;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

/**
 * 系统公告表 Domain
 *
 * @author Administrator
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
@TableName("sys_announcement")
public class AnnouncementDomain extends AbstractAuditableDomain {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
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

    /**
     * 版本号（展示）
     */
    @Schema(description = "版本号（展示），如 1.2.0")
    private String versionLabel;

    /**
     * 可见最小客户端 versionCode（含）；空不限制
     */
    @Schema(description = "可见最小客户端 versionCode（含），空表示不限制")
    private Integer minVersionCode;

    /**
     * 可见最大客户端 versionCode（含）；空不限制
     */
    @Schema(description = "可见最大客户端 versionCode（含），空表示不限制")
    private Integer maxVersionCode;

}