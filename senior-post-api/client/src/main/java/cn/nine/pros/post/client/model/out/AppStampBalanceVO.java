package cn.nine.pros.post.client.model.out;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "邮票余额与 VIP 摘要")
public class AppStampBalanceVO {

    @Schema(description = "当前邮票余额")
    private Integer stampsBalance;

    @Schema(description = "是否 VIP")
    private Boolean isVip;

    @Schema(description = "VIP 到期时间，非 VIP 可为 null")
    private LocalDateTime vipExpireAt;
}
