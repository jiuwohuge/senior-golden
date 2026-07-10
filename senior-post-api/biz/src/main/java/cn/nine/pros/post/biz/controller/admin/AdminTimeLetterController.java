package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.biz.service.biz.admin.AdminTimeLetterService;
import cn.nine.pros.post.client.api.admin.AdminTimeLetterApi;
import cn.nine.pros.post.client.model.db.TimeLetterDTO;
import cn.nine.pros.post.client.model.input.admin.TimeLetterQueryInDto;
import cn.nine.pros.post.client.model.input.admin.TimeLetterTakedownInDto;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class AdminTimeLetterController implements AdminTimeLetterApi {

    private final AdminTimeLetterService adminTimeLetterService;

    @Override
    public PageData<TimeLetterDTO> paging(TimeLetterQueryInDto body) {
        return adminTimeLetterService.paging(body);
    }

    @Override
    public TimeLetterDTO getDetail(Long id) {
        return adminTimeLetterService.getDetail(id);
    }

    @Override
    public void takedown(Long id, TimeLetterTakedownInDto body) {
        adminTimeLetterService.takedown(id, body.getReason());
    }
}
