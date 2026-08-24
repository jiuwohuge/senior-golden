package cn.nine.pros.post.biz.model.domain;

import cn.nine.commons.data.domain.AbstractAuditableDomain;
import com.baomidou.mybatisplus.annotation.IdType;
import java.time.LocalDateTime;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import cn.nine.pros.post.biz.support.mybatis.PostgresJsonbTypeHandler;
import cn.nine.pros.post.client.model.json.LetterContentMeta;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;


/**
 * Letter domain (bu_letter)
 *
 * @author Administrator
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
@TableName(value = "bu_letter", autoResultMap = true)
public class LetterDomain extends AbstractAuditableDomain {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    @Schema(description = "letter id")
    private Long id;

    @Schema(description = "from user id")
    private Long fromUserId;

    @Schema(description = "to user id (nullable for POST_OFFICE pool)")
    private Long toUserId;

    @Schema(description = "legacy physical type: 1 registered-shape 2 standard")
    private Object letterType;

    @Schema(description = "status: 0PENDING 1DELIVERING 2DELIVERED 3REGISTERED 4MATCHED")
    private Object status;

    @Schema(description = "letter content")
    private String content;

    @Schema(description = "expected arrival time (distance + relationship delay)")
    private Object expectedArrivalTime;

    @Schema(description = "actual arrival time")
    private Object actualArrivalTime;

    @Schema(description = "parent letter id (reply)")
    private Long parentLetterId;

    @Schema(description = "send mode rail (legacy compatibility)")
    private Integer sendMode;

    @Schema(description = "product mode: 1POST_OFFICE 2DIRECT 3SELF_TIME")
    private Integer mode;

    @Schema(description = "audit status: 0PENDING_REVIEW 1APPROVED 2REJECTED")
    private Integer auditStatus;

    @Schema(description = "POST_OFFICE matched at")
    private LocalDateTime matchedAt;

    @Schema(description = "recipient first read at")
    @TableField("recipient_read_at")
    private LocalDateTime recipientReadAt;

    @Schema(description = "skin/font/template content meta")
    @TableField(value = "content_meta_json", typeHandler = PostgresJsonbTypeHandler.class)
    private LetterContentMeta contentMetaJson;

    /**
     * 写信主题邮票，可空；本轮匹配不读此列。
     */
    @Schema(description = "写信主题邮票 sys_tag.id")
    private Integer topicTagId;

}
