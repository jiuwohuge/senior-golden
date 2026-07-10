package cn.nine.pros.post.biz.service.biz.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.controller.admin.AdminPageHelper;
import cn.nine.pros.post.biz.model.domain.SensitiveWordDomain;
import cn.nine.pros.post.biz.model.mapstruct.SensitiveWordMapstruct;
import cn.nine.pros.post.biz.service.base.SensitiveWordService;
import cn.nine.pros.post.client.model.db.SensitiveWordDTO;
import cn.nine.pros.post.client.model.input.admin.SensitiveWordInDto;
import cn.nine.pros.post.client.model.input.admin.SensitiveWordQueryInDto;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 管理端敏感词 CRUD。
 */
@Service
@RequiredArgsConstructor
public class AdminSensitiveWordBizService {

    private final SensitiveWordService sensitiveWordService;
    private final SensitiveWordMapstruct sensitiveWordMapstruct;

    /**
     * 按词条/语言分页查询敏感词。
     */
    public PageData<SensitiveWordDTO> paging(SensitiveWordQueryInDto body) {
        PageQuery pageQuery = AdminPageHelper.normalize(body.getPage());
        Page<SensitiveWordDomain> p = sensitiveWordService.pageForAdmin(pageQuery, body.getWord(), body.getLangCode());
        List<SensitiveWordDTO> list = p.getRecords().stream().map(sensitiveWordMapstruct::toDTO).collect(Collectors.toList());
        return AdminPageHelper.pageData(pageQuery, p, list);
    }

    /**
     * 新增或更新敏感词。
     */
    public void save(SensitiveWordInDto body) {
        SensitiveWordDTO dto = new SensitiveWordDTO();
        dto.setId(body.getId());
        dto.setWord(body.getWord());
        dto.setLangCode(body.getLangCode());
        dto.setType(body.getType() == null ? null : String.valueOf(body.getType()));
        dto.setTypeText(body.getDescription());
        sensitiveWordService.upsert(dto);
    }

    /**
     * 按主键删除敏感词。
     */
    public void delete(Integer id) {
        sensitiveWordService.delByIds(List.of(id));
    }
}
