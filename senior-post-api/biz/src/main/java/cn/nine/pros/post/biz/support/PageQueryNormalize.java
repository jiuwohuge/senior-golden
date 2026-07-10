package cn.nine.pros.post.biz.support;

import cn.nine.commons.data.page.PageQuery;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;

/**
 * 分页参数归一化：供 Base ServiceImpl 与 Admin/App PageHelper 复用，避免重复三元。
 */
public final class PageQueryNormalize {

    public static final long DEFAULT_PAGE = 1L;
    public static final long DEFAULT_SIZE = 20L;
    public static final long ADMIN_MAX_SIZE = 200L;
    public static final long APP_MAX_SIZE = 100L;

    private PageQueryNormalize() {
    }

    /** 页码：缺失或 &lt;1 时返回 1。 */
    public static long pageIndex(PageQuery pageQuery) {
        if (pageQuery == null || pageQuery.getPage() == null || pageQuery.getPage() < 1) {
            return DEFAULT_PAGE;
        }
        return pageQuery.getPage();
    }

    /** 页大小：缺失、&lt;1 或超过 maxSize 时返回默认 20。 */
    public static long pageSize(PageQuery pageQuery, long maxSize) {
        if (pageQuery == null || pageQuery.getSize() == null
                || pageQuery.getSize() < 1 || pageQuery.getSize() > maxSize) {
            return DEFAULT_SIZE;
        }
        return pageQuery.getSize();
    }

    /** MyBatis-Plus 分页对象。 */
    public static <T> Page<T> mpPage(PageQuery pageQuery, long maxSize) {
        return new Page<>(pageIndex(pageQuery), pageSize(pageQuery, maxSize));
    }
}
