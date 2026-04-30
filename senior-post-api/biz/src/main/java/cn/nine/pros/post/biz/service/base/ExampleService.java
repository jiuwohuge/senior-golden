package cn.nine.pros.post.biz.service.base;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.biz.model.domain.ExampleDomain;
import cn.nine.pros.post.client.model.db.ExampleDTO;
import cn.nine.pros.post.client.model.input.ExamplePageInDto;
import com.baomidou.mybatisplus.extension.service.IService;

import java.util.List;

/**
 * ${classComments} Service
 *
 * @author Administrator
 */
public interface ExampleService extends IService<ExampleDomain> {

    PageData<ExampleDTO> paging(ExamplePageInDto param);

    void upsert(ExampleDTO exampleDTO);

    ExampleDTO findById(String id);

    void delByIds(List<String> ids);

}