package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.model.domain.TimeLetterDomain;
import cn.nine.pros.post.biz.service.biz.admin.AdminTimeLetterService;
import cn.nine.pros.post.biz.service.base.TimeLetterService;
import cn.nine.pros.post.client.api.admin.AdminTimeLetterApi;
import cn.nine.pros.post.client.model.db.TimeLetterDTO;
import cn.nine.pros.post.client.model.input.admin.TimeLetterQueryInDto;
import cn.nine.pros.post.client.model.input.admin.TimeLetterTakedownInDto;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequiredArgsConstructor
public class AdminTimeLetterController implements AdminTimeLetterApi {

    private final AdminTimeLetterService adminTimeLetterService;
    private final TimeLetterService timeLetterService;

    @Override
    public PageData<TimeLetterDTO> paging(TimeLetterQueryInDto body) {
        PageQuery pageQuery = AdminPageHelper.normalize(body == null ? null : body.getPage());
        LambdaQueryWrapper<TimeLetterDomain> qw = new LambdaQueryWrapper<TimeLetterDomain>()
                .eq(TimeLetterDomain::isDelFlag, false)
                .orderByDesc(TimeLetterDomain::getCreatedAt);
        if (body != null) {
            if (body.getSenderId() != null) {
                qw.eq(TimeLetterDomain::getSenderId, body.getSenderId());
            }
            if (body.getRecipientId() != null) {
                qw.eq(TimeLetterDomain::getRecipientId, body.getRecipientId());
            }
            if (body.getStatus() != null) {
                qw.eq(TimeLetterDomain::getStatus, body.getStatus());
            }
        }
        Page<TimeLetterDomain> p = timeLetterService.page(AdminPageHelper.mpPage(pageQuery), qw);
        List<TimeLetterDTO> list = p.getRecords().stream()
                .map(adminTimeLetterService::toDto)
                .collect(Collectors.toList());
        return AdminPageHelper.pageData(pageQuery, p, list);
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
