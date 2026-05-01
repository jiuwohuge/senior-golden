package cn.nine.pros.post.biz.model.domain;

import cn.nine.commons.data.domain.AbstractAuditableDomain;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

/**
 * 系统配置表 Domain
 *
 * @author Administrator
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
@TableName("sys_config")
public class ConfigDomain extends AbstractAuditableDomain {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    @Schema(description = "配置ID")
    private Integer id;
    /**
     * 配置键
     */
    @Schema(description = "配置键")
    private String configKey;
    /**
     * 配置值
     */
    @Schema(description = "配置值")
    private String configValue;
    /**
     * 配置分组（register/vip/stamps/system等）
     */
    @Schema(description = "配置分组（register/vip/stamps/system等）")
    private String configGroup;
    /**
     * 配置描述
     */
    @Schema(description = "配置描述")
    private String description;

}