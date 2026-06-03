package cn.nine.pros.post.client.api.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.db.TimeLetterDTO;
import cn.nine.pros.post.client.model.input.admin.TimeLetterQueryInDto;
import cn.nine.pros.post.client.model.input.admin.TimeLetterTakedownInDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

@Tag(name = "管理后台-时光信")
@RequestMapping(AppServiceDefine.WEBAPI_PREFIX + "/content/time-letter")
public interface AdminTimeLetterApi {

    @Operation(summary = "分页查询时光信")
    @PostMapping("/paging")
    PageData<TimeLetterDTO> paging(@RequestBody @Valid TimeLetterQueryInDto body);

    @Operation(summary = "时光信详情")
    @GetMapping("/{id}")
    TimeLetterDTO getDetail(@PathVariable("id") Long id);

    @Operation(summary = "下架时光信")
    @PostMapping("/{id}/takedown")
    void takedown(@PathVariable("id") Long id, @RequestBody @Valid TimeLetterTakedownInDto body);
}
