package cn.nine.pros.post.biz.model.domain;

import cn.nine.commons.data.domain.AbstractAuditableDomain;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

/**
 * 兴趣标签表 Domain
 *
 * @author Administrator
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
@TableName("sys_tag")
public class TagDomain extends AbstractAuditableDomain {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    @Schema(description = "标签ID")
    private Integer id;
    /**
     * 标签名称
     */
    @Schema(description = "标签名称")
    private String tagName;
    /**
     * 语言代码（en/zh/ja/ko等）
     */
    @Schema(description = "语言代码（en/zh/ja/ko等）")
    private String langCode;
    /**
     * 排序顺序
     */
    @Schema(description = "排序顺序")
    private Integer sortOrder;

    /**
     * 标签分栏：interest=兴趣目录；letter_topic=写信主题邮票。
     */
    @Schema(description = "interest | letter_topic")
    private String tagKind;

    /**
     * 稳定业务码；兴趣旧行可空。
     */
    @Schema(description = "标签业务码")
    private String tagCode;

}