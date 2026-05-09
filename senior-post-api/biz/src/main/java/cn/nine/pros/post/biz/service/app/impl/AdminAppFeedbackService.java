package cn.nine.pros.post.biz.service.app.impl;

import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.mapper.AppFeedbackMapper;
import cn.nine.pros.post.biz.model.domain.AppFeedbackDomain;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.client.model.db.UserDTO;
import cn.nine.pros.post.client.model.input.admin.AppFeedbackAdminQueryInDto;
import cn.nine.pros.post.client.model.out.AppFeedbackAdminItemVO;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AdminAppFeedbackService {

    private final AppFeedbackMapper appFeedbackMapper;
    private final UserService userService;

    public PageData<AppFeedbackAdminItemVO> paging(AppFeedbackAdminQueryInDto body) {
        PageQuery pq = normalizePage(body == null ? null : body.getPage());
        LambdaQueryWrapper<AppFeedbackDomain> qw = new LambdaQueryWrapper<AppFeedbackDomain>()
                .eq(AppFeedbackDomain::isDelFlag, false)
                .orderByDesc(AppFeedbackDomain::getCreatedAt);
        Page<AppFeedbackDomain> p = appFeedbackMapper.selectPage(mpPage(pq), qw);
        List<AppFeedbackAdminItemVO> list = p.getRecords().stream().map(this::toVo).collect(Collectors.toList());
        return pageData(pq, p, list);
    }

    private static PageQuery normalizePage(PageQuery page) {
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

    private static <T> Page<T> mpPage(PageQuery pageQuery) {
        return new Page<>(pageQuery.getPage(), pageQuery.getSize());
    }

    private static <T> PageData<T> pageData(PageQuery pageQuery, Page<?> page, List<T> records) {
        return PageData.of(page.getTotal(), pageQuery.getPage(), pageQuery.getSize(), records);
    }

    private AppFeedbackAdminItemVO toVo(AppFeedbackDomain row) {
        UserDTO u = userService.findById(row.getUserId());
        String nick = u != null && u.getNickname() != null ? u.getNickname() : "";
        return AppFeedbackAdminItemVO.builder()
                .id(row.getId())
                .userId(row.getUserId())
                .nickname(nick)
                .content(row.getContent())
                .clientVersion(row.getClientVersion())
                .createdAt(toLdt(row.getCreatedAt()))
                .build();
    }

    private static java.time.LocalDateTime toLdt(Object raw) {
        if (raw == null) {
            return null;
        }
        if (raw instanceof java.time.LocalDateTime ldt) {
            return ldt;
        }
        if (raw instanceof java.sql.Timestamp ts) {
            return ts.toLocalDateTime();
        }
        return null;
    }
}
