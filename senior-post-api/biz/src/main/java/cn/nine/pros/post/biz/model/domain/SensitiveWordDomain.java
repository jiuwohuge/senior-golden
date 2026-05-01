package cn.nine.pros.post.biz.model.domain;

import cn.nine.commons.data.domain.AbstractAuditableDomain;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

/**
 * 敏感词库表 Domain
 *
 * @author Administrator
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
@TableName("sys_sensitive_word")
public class SensitiveWordDomain extends AbstractAuditableDomain {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    @Schema(description = "敏感词ID")
    private Integer id;
    /**
     * 敏感词
     */
    @Schema(description = "敏感词")
    private String word;
    /**
     * 分类（porn/politics/ad等）
     */
    @Schema(description = "分类（porn/politics/ad等）")
    private String type;
    /**
     * 分类描述（多语言）
     */
    @Schema(description = "分类描述（多语言）")
    private String typeText;
    /**
     * 语言代码（en/zh/ja/ko等）
     */
    @Schema(description = "语言代码（en/zh/ja/ko等）")
    private String langCode;

}