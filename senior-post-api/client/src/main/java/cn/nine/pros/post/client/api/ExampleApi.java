package cn.nine.pros.post.client.api;


import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.client.model.db.ExampleDTO;
import cn.nine.pros.post.client.model.input.ExamplePageInDto;
import cn.nine.pros.post.client.model.out.ExampleVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;

@Tag(name = "示例API")
public interface ExampleApi {

    @Operation(summary = "查询示例")
    @PostMapping("find")
    ExampleDTO findExample(@RequestParam("id") Long id);

    @Operation(summary = "分页查询示例")
    @PostMapping("paging")
    PageData<ExampleDTO> pagingExample(@RequestBody @Validated ExamplePageInDto param);

}
