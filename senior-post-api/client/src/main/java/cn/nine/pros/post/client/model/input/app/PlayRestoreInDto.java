package cn.nine.pros.post.client.model.input.app;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.util.List;

@Data
@Schema(description = "恢复购买：可带本地购买列表，或空列表仅重读服务端")
public class PlayRestoreInDto {

    @Schema(description = "本地已知购买；可空")
    private List<PlayPurchaseVerifyInDto> purchases;
}
