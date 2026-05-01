package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.model.domain.SensitiveWordDomain;
import cn.nine.pros.post.biz.model.mapstruct.SensitiveWordMapstruct;
import cn.nine.pros.post.biz.service.base.SensitiveWordService;
import cn.nine.pros.post.client.api.admin.AdminSensitiveWordApi;
import cn.nine.pros.post.client.model.db.SensitiveWordDTO;
import cn.nine.pros.post.client.model.input.admin.SensitiveWordInDto;
import cn.nine.pros.post.client.model.input.admin.SensitiveWordQueryInDto;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.apache.commons.lang3.StringUtils;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequiredArgsConstructor
public class AdminSensitiveWordController implements AdminSensitiveWordApi {

    private final SensitiveWordService sensitiveWordService;
    private final SensitiveWordMapstruct sensitiveWordMapstruct;

    @Override
    public PageData<SensitiveWordDTO> paging(SensitiveWordQueryInDto body) {
        PageQuery pageQuery = AdminPageHelper.normalize(body.getPage());
        LambdaQueryWrapper<SensitiveWordDomain> qw = new LambdaQueryWrapper<SensitiveWordDomain>()
                .eq(SensitiveWordDomain::isDelFlag, false)
                .orderByDesc(SensitiveWordDomain::getCreatedAt);
        if (StringUtils.isNotBlank(body.getWord())) {
            qw.like(SensitiveWordDomain::getWord, body.getWord().trim());
        }
        if (StringUtils.isNotBlank(body.getLangCode())) {
            qw.eq(SensitiveWordDomain::getLangCode, body.getLangCode().trim());
        }
        Page<SensitiveWordDomain> p = sensitiveWordService.page(AdminPageHelper.mpPage(pageQuery), qw);
        List<SensitiveWordDTO> list = p.getRecords().stream().map(sensitiveWordMapstruct::toDTO).collect(Collectors.toList());
        return AdminPageHelper.pageData(pageQuery, p, list);
    }

    @Override
    public void save(SensitiveWordInDto body) {
        SensitiveWordDTO dto = new SensitiveWordDTO();
        dto.setId(body.getId());
        dto.setWord(body.getWord());
        dto.setLangCode(body.getLangCode());
        dto.setType(body.getType() == null ? null : String.valueOf(body.getType()));
        dto.setTypeText(body.getDescription());
        sensitiveWordService.upsert(dto);
    }

    @Override
    public void delete(Integer id) {
        sensitiveWordService.delByIds(java.util.List.of(id));
    }
}
