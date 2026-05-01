package cn.nine.pros.post.client.api.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.db.ConfigDTO;
import cn.nine.pros.post.client.model.input.admin.ConfigInDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "管理后台-配置中心API")
public interface AdminConfigApi {

    @Operation(summary = "配置列表")
    @GetMapping(AppServiceDefine.WEBAPI_PREFIX + "/config/list")
    List<ConfigDTO> listConfigs(@RequestParam(value = "group", required = false) String group);

    @Operation(summary = "创建配置")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/config")
    void createConfig(@RequestBody @Validated ConfigInDto config);

    @Operation(summary = "更新配置")
    @PutMapping(AppServiceDefine.WEBAPI_PREFIX + "/config/{id}")
    void updateConfig(@PathVariable("id") Integer id, @RequestBody @Validated ConfigInDto config);

    @Operation(summary = "删除配置")
    @DeleteMapping(AppServiceDefine.WEBAPI_PREFIX + "/config/{id}")
    void deleteConfig(@PathVariable("id") Integer id);

    @Operation(summary = "VIP权益配置列表")
    @GetMapping(AppServiceDefine.WEBAPI_PREFIX + "/vip/config/list")
    List<ConfigDTO> listVipConfigs();

    @Operation(summary = "更新VIP权益配置")
    @PutMapping(AppServiceDefine.WEBAPI_PREFIX + "/vip/config")
    void updateVipConfig(@RequestBody @Validated ConfigInDto config);
}