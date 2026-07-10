package cn.nine.pros.post.biz.controller.admin;

import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.support.PageQueryNormalize;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;

import java.util.List;

public final class AdminPageHelper {
    private AdminPageHelper() {}

    public static PageQuery normalize(PageQuery page) {
        if (page == null) {
            page = new PageQuery();
        }
        page.setPage(PageQueryNormalize.pageIndex(page));
        page.setSize(PageQueryNormalize.pageSize(page, PageQueryNormalize.ADMIN_MAX_SIZE));
        return page;
    }

    public static <T> Page<T> mpPage(PageQuery pageQuery) {
        return PageQueryNormalize.mpPage(pageQuery, PageQueryNormalize.ADMIN_MAX_SIZE);
    }

    public static <T> PageData<T> pageData(PageQuery pageQuery, Page<?> page, List<T> records) {
        return PageData.of(page.getTotal(), pageQuery.getPage(), pageQuery.getSize(), records);
    }
}
