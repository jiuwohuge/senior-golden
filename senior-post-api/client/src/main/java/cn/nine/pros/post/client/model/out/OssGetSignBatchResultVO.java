package cn.nine.pros.post.client.model.out;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "批量 GET 预签名结果（与请求 objectKeys 顺序一致）")
public class OssGetSignBatchResultVO {

    private List<OssGetSignItemVO> items;
}
