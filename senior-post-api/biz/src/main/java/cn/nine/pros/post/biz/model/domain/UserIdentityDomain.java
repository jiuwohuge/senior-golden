package cn.nine.pros.post.biz.model.domain;

import cn.nine.commons.data.domain.AbstractAuditableDomain;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString(callSuper = true)
@EqualsAndHashCode(callSuper = true)
@TableName("bu_user_identity")
public class UserIdentityDomain extends AbstractAuditableDomain {

    @TableId(type = IdType.AUTO)
    private Long id;

    @Schema(description = "用户 ID")
    private Long userId;

    @Schema(description = "email | google | apple")
    private String provider;

    @Schema(description = "邮箱或 OAuth sub")
    private String providerUid;

    @Schema(description = "仅 email 身份存密码哈希")
    private String passwordHash;
}
