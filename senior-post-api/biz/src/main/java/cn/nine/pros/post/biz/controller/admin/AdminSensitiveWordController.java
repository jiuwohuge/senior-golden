package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.model.domain.SensitiveWordDomain;
import cn.nine.pros.post.biz.model.mapstruct.SensitiveWordMapstruct;
import cn.nine.pros.post.biz.service.base.SensitiveWordService;
import cn.nine.pros.post.client.api.admin.AdminSensitiveWordApi;
import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.db.SensitiveWordDTO;
import cn.nine.pros.post.client.model.input.admin.SensitiveWordInDto;
import cn.nine.pros.post.client.model.input.admin.SensitiveWordQueryInDto;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequiredArgsConstructor
@Tag(name = "管理后台-敏感词管理API")
public class AdminSensitiveWordController implements AdminSensitiveWordApi {

    private final SensitiveWordService sensitiveWordService;
    private final SensitiveWordMapstruct sensitiveWordMapstruct;

    @Override
    @Operation(summary = "敏感词列表")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/sensitive-word/list")
    public PageData<SensitiveWordDTO> listSensitiveWords(@RequestBody SensitiveWordQueryInDto query) {
        PageQuery pageQuery = query.getPage();
        long pageNum = pageQuery.getPage();
        long pageSize = pageQuery.getSize();

        LambdaQueryWrapper<SensitiveWordDomain> wrapper = new LambdaQueryWrapper<>();
        if (query.getWord() != null && !query.getWord().isEmpty()) {
            wrapper.like(SensitiveWordDomain::getWord, query.getWord());
        }
        if (query.getLangCode() != null && !query.getLangCode().isEmpty()) {
            wrapper.eq(SensitiveWordDomain::getLangCode, query.getLangCode());
        }
        wrapper.eq(SensitiveWordDomain::isDelFlag, false);
        wrapper.orderByDesc(SensitiveWordDomain::getCreatedAt);

        Page<SensitiveWordDomain> page = sensitiveWordService.page(new Page<>((int) pageNum, (int) pageSize), wrapper);
        List<SensitiveWordDTO> records = page.getRecords().stream().map(sensitiveWordMapstruct::toDTO).toList();

        PageData<SensitiveWordDTO> result = new PageData<>();
        result.setRecords(records);
        result.setTotal(page.getTotal());
        result.setPages(page.getPages());
        result.setPage(page.getCurrent());
        result.setSize(page.getSize());
        return result;
    }

    @Override
    @Operation(summary = "创建敏感词")
    @PostMapping(AppServiceDefine.WEBAPI_PREFIX + "/sensitive-word")
    @Transactional
    public void createSensitiveWord(@RequestBody SensitiveWordInDto word) {
        SensitiveWordDomain domain = new SensitiveWordDomain();
        domain.setWord(word.getWord());
        domain.setLangCode(word.getLangCode());
        domain.setType(word.getType());
        domain.setTypeText(word.getTypeText());
        domain.initAudit(MyRequestContextHolder.userId());
        sensitiveWordService.save(domain);
    }

    @Override
    @Operation(summary = "更新敏感词")
    @PutMapping(AppServiceDefine.WEBAPI_PREFIX + "/sensitive-word/{id}")
    @Transactional
    public void updateSensitiveWord(@PathVariable("id") Integer id, @RequestBody SensitiveWordInDto word) {
        SensitiveWordDomain domain = sensitiveWordService.getById(id);
        if (domain == null) {
            throw new cn.nine.commons.basic.exception.BadRequestException("敏感词不存在");
        }
        domain.setWord(word.getWord());
        domain.setLangCode(word.getLangCode());
        domain.setType(word.getType());
        domain.setTypeText(word.getTypeText());
        domain.updateAudit(MyRequestContextHolder.userId());
        sensitiveWordService.updateById(domain);
    }

    @Override
    @Operation(summary = "删除敏感词")
    @DeleteMapping(AppServiceDefine.WEBAPI_PREFIX + "/sensitive-word/{id}")
    @Transactional
    public void deleteSensitiveWord(@PathVariable("id") Integer id) {
        SensitiveWordDomain domain = sensitiveWordService.getById(id);
        if (domain == null) {
            throw new cn.nine.commons.basic.exception.BadRequestException("敏感词不存在");
        }
        domain.setDelFlag(true);
        sensitiveWordService.updateById(domain);
    }
}