package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.mapper.ExampleMapper;
import cn.nine.pros.post.biz.model.domain.ExampleDomain;
import cn.nine.pros.post.biz.model.mapstruct.ExampleMapstruct;
import cn.nine.pros.post.biz.service.base.ExampleService;
import cn.nine.pros.post.client.model.db.ExampleDTO;
import cn.nine.pros.post.client.model.input.ExamplePageInDto;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;


/**
 * ${classComments} ServiceImpl
 *
 * @author Administrator
 */
@Service
public class ExampleServiceImpl extends ServiceImpl<ExampleMapper, ExampleDomain>
        implements ExampleService {

    @Autowired
    private ExampleMapstruct exampleMapstruct;

    @Override
    public PageData<ExampleDTO> paging(ExamplePageInDto param) {
        // 构建查询条件
        LambdaQueryWrapper<ExampleDomain> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(ExampleDomain::isDelFlag, false);
        // 分页查询
        PageQuery page = param.getPage();
        Page<ExampleDomain> resultPage = page(new Page<>(page.getPage(), page.getSize()),
                queryWrapper);
        // 转换为DTO
        List<ExampleDTO> list = resultPage.getRecords().stream()
                .map(exampleMapstruct::toDTO)
                .collect(Collectors.toList());
        return PageData.of(resultPage.getTotal(), page.getPage(), page.getSize(), list);
    }

    @Override
    public void upsert(ExampleDTO exampleDTO) {
        Long id = exampleDTO.getId();
        if (id == null) {
            ExampleDomain domain = exampleMapstruct.toDomain(exampleDTO);
            domain.initAudit(MyRequestContextHolder.userId());
            save(domain);
            return;
        }
        ExampleDomain domain = exampleMapstruct.toDomain(exampleDTO);
        domain.setId(id);
        domain.setUpdatedAt(LocalDateTime.now());
        domain.setUpdatedBy(MyRequestContextHolder.userId());
        updateById(domain);
    }

    @Override
    public ExampleDTO findById(String id) {
        return exampleMapstruct.toDTO(getById(id));
    }

    @Override
    public void delByIds(List<String> ids) {
        ExampleDomain exampleDomain = new ExampleDomain();
        exampleDomain.setDelFlag(true);
        exampleDomain.setUpdatedAt(LocalDateTime.now());
        update(exampleDomain, new LambdaQueryWrapper<ExampleDomain>()
                .in(ExampleDomain::getId, ids));
    }

}