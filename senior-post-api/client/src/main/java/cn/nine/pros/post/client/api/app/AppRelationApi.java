package cn.nine.pros.post.client.api.app;

import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.input.app.CreatePenpalRequestInDto;
import cn.nine.pros.post.client.model.out.PenpalRequestResultVO;
import cn.nine.pros.post.client.model.out.RelationSnapshotVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

@Tag(name = "App-关系")
@RequestMapping(AppServiceDefine.SERVER_PREFIX + "/relation")
public interface AppRelationApi {

    @Operation(summary = "与指定用户的关系快照（§10.3）")
    @GetMapping("/with/{userId}")
    RelationSnapshotVO relationWith(@PathVariable("userId") Long userId);

    @Operation(summary = "发起笔友申请")
    @PostMapping("/penpal/requests")
    PenpalRequestResultVO createPenpalRequest(@RequestBody @Valid CreatePenpalRequestInDto body);

    @Operation(summary = "同意笔友申请")
    @PostMapping("/penpal/requests/{requestId}/accept")
    PenpalRequestResultVO acceptPenpalRequest(@PathVariable("requestId") Long requestId);

    @Operation(summary = "忽略笔友申请")
    @PostMapping("/penpal/requests/{requestId}/ignore")
    PenpalRequestResultVO ignorePenpalRequest(@PathVariable("requestId") Long requestId);
}
