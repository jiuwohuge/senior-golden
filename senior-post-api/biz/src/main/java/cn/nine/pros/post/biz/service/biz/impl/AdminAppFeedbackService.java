package cn.nine.pros.post.biz.service.biz.impl;

import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.controller.admin.AdminPageHelper;
import cn.nine.pros.post.biz.model.domain.AppFeedbackDomain;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.client.model.db.UserDTO;
import cn.nine.pros.post.client.model.input.admin.AppFeedbackAdminQueryInDto;
import cn.nine.pros.post.client.model.out.AppFeedbackAdminItemVO;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 管理端 App 反馈列表查询。
 */
@Service
@RequiredArgsConstructor
public class AdminAppFeedbackService {

    private final cn.nine.pros.post.biz.service.base.AppFeedbackService appFeedbackService;
    private final UserService userService;

    /**
     * 分页查询 App 反馈并附带用户昵称。
     */
    public PageData<AppFeedbackAdminItemVO> paging(AppFeedbackAdminQueryInDto body) {
        PageQuery pq = AdminPageHelper.normalize(body == null ? null : body.getPage());
        Page<AppFeedbackDomain> p = appFeedbackService.pageForAdmin(pq);
        List<AppFeedbackAdminItemVO> list = p.getRecords().stream().map(this::toVo).collect(Collectors.toList());
        return AdminPageHelper.pageData(pq, p, list);
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
