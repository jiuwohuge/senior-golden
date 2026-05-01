package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;

import java.util.List;

final class AdminPageHelper {
    private AdminPageHelper() {}

    static PageQuery normalize(PageQuery page) {
        if (page == null) {
            page = new PageQuery();
            page.setPage(1L);
            page.setSize(20L);
            return page;
        }
        if (page.getPage() == null || page.getPage() < 1) {
            page.setPage(1L);
        }
        if (page.getSize() == null || page.getSize() < 1 || page.getSize() > 200) {
            page.setSize(20L);
        }
        return page;
    }

    static <T> Page<T> mpPage(PageQuery pageQuery) {
        return new Page<>(pageQuery.getPage(), pageQuery.getSize());
    }

    static <T> PageData<T> pageData(PageQuery pageQuery, Page<?> page, List<T> records) {
        return PageData.of(page.getTotal(), pageQuery.getPage(), pageQuery.getSize(), records);
    }
}
