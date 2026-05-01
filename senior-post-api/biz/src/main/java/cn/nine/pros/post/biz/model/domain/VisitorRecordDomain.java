package cn.nine.pros.post.biz.model.domain;

import cn.nine.commons.data.domain.AbstractAuditableDomain;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

/**
 * 访客记录表 Domain
 *
 * @author Administrator
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
@TableName("bu_visitor_record")
public class VisitorRecordDomain extends AbstractAuditableDomain {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    @Schema(description = "记录ID")
    private Long id;
    /**
     * 访问者ID
     */
    @Schema(description = "访问者ID")
    private Long visitorId;
    /**
     * 被访问者ID
     */
    @Schema(description = "被访问者ID")
    private Long visitedId;
    /**
     * 访问类型：1查看资料 2查看明信片
     */
    @Schema(description = "访问类型：1查看资料 2查看明信片")
    private Object visitType;

}