package cn.nine.pros.post.client.model.db;

import cn.nine.commons.data.dto.AbstractAuditableDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

/**
 * 系统配置表 DTO
 *
 * @author Administrator
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
public class ConfigDTO extends AbstractAuditableDTO {

    private static final long serialVersionUID = 1L;

    /**
     * 配置ID
     */
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