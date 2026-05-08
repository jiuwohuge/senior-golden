package cn.nine.pros.post.biz.service.app.impl;

import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.controller.app.AppPageHelper;
import cn.nine.pros.post.biz.model.domain.UserDomain;
import cn.nine.pros.post.biz.service.app.AppDirectoryService;
import cn.nine.pros.post.biz.service.base.OssDisplayUrlService;
import cn.nine.pros.post.biz.service.base.UserService;
import cn.nine.pros.post.client.model.input.app.AppDirectoryPageInDto;
import cn.nine.pros.post.client.model.out.DirectoryUserItemVO;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AppDirectoryServiceImpl implements AppDirectoryService {

    private static final int USER_STATUS_NORMAL = 1;

    private static final String SORT_DEFAULT = "DEFAULT";
    private static final String SORT_SAME_AGE = "SAME_AGE";
    private static final String SORT_SHARED_INTEREST = "SHARED_INTEREST";

    private final UserService userService;
    private final OssDisplayUrlService ossDisplayUrlService;

    @Override
    public PageData<DirectoryUserItemVO> pageUsers(long viewerUserId, AppDirectoryPageInDto body) {
        PageQuery pq = AppPageHelper.normalize(body == null ? null : body.getPage());
        LambdaQueryWrapper<UserDomain> qw = new LambdaQueryWrapper<UserDomain>()
                .eq(UserDomain::isDelFlag, false)
                .apply("status = 1")
                .eq(UserDomain::getStaffRole, 0)
                .ne(UserDomain::getId, viewerUserId);

        applySort(qw, viewerUserId, body);

        if (body != null && StringUtils.hasText(body.getCountryCode())) {
            qw.eq(UserDomain::getCountryCode, body.getCountryCode().trim());
        }
        int year = LocalDate.now().getYear();
        if (body != null && body.getMinAge() != null && body.getMinAge() > 0) {
            qw.le(UserDomain::getBirthYear, year - body.getMinAge());
        }
        if (body != null && body.getMaxAge() != null && body.getMaxAge() > 0) {
            qw.ge(UserDomain::getBirthYear, year - body.getMaxAge());
        }
        if (body != null && body.getInterestNames() != null && !body.getInterestNames().isEmpty()) {
            List<String> names = body.getInterestNames().stream()
                    .filter(StringUtils::hasText)
                    .map(String::trim)
                    .distinct()
                    .collect(Collectors.toList());
            for (String n : names) {
                qw.apply("EXISTS (SELECT 1 FROM bu_user_tag ut INNER JOIN sys_tag t ON t.id = ut.tag_id AND t.del_flag = FALSE "
                        + "WHERE ut.user_id = bu_user.id AND ut.del_flag = FALSE AND t.tag_name = {0})", n);
            }
        }

        Page<UserDomain> p = userService.page(AppPageHelper.mpPage(pq), qw);
        List<DirectoryUserItemVO> records = new ArrayList<>();
        for (UserDomain u : p.getRecords()) {
            records.add(toVo(viewerUserId, u));
        }
        return AppPageHelper.pageData(pq, p, records);
    }

    @Override
    public DirectoryUserItemVO getDirectoryUser(long viewerUserId, long targetUserId) {
        UserDomain u = userService.getById(targetUserId);
        if (u == null || u.isDelFlag()) {
            throw new BadRequestException("用户不存在");
        }
        if (!isDirectoryListableUser(u)) {
            throw new BadRequestException("该用户暂不可见");
        }
        return toVo(viewerUserId, u);
    }

    private void applySort(LambdaQueryWrapper<UserDomain> qw, long viewerUserId, AppDirectoryPageInDto body) {
        String sort = SORT_DEFAULT;
        if (body != null && StringUtils.hasText(body.getSort())) {
            sort = body.getSort().trim().toUpperCase();
        }
        if (!SORT_SAME_AGE.equals(sort) && !SORT_SHARED_INTEREST.equals(sort)) {
            qw.orderByDesc(UserDomain::getCreatedAt);
            return;
        }
        if (SORT_SAME_AGE.equals(sort)) {
            UserDomain viewer = userService.getById(viewerUserId);
            Integer vy = viewer != null ? viewer.getBirthYear() : null;
            if (vy != null && vy > 0) {
                qw.last("ORDER BY CASE WHEN birth_year IS NULL THEN 999 ELSE ABS(birth_year - "
                        + vy + ") END ASC, created_at DESC");
            } else {
                qw.orderByDesc(UserDomain::getCreatedAt);
            }
            return;
        }
        // SHARED_INTEREST：与浏览者共同标签数降序，再按注册时间
        qw.last("ORDER BY (SELECT COUNT(*)::int FROM bu_user_tag ut INNER JOIN bu_user_tag ut2 ON ut.tag_id = ut2.tag_id "
                + "AND ut2.user_id = " + viewerUserId + " AND ut2.del_flag = FALSE "
                + "WHERE ut.user_id = bu_user.id AND ut.del_flag = FALSE) DESC NULLS LAST, created_at DESC");
    }

    private DirectoryUserItemVO toVo(long viewerUserId, UserDomain u) {
        String av = u.getAvatarUrl();
        if (StringUtils.hasText(av)) {
            av = ossDisplayUrlService.signAvatarForViewer(viewerUserId, av.trim());
        }
        return DirectoryUserItemVO.builder()
                .id(u.getId())
                .nickname(u.getNickname())
                .countryCode(u.getCountryCode())
                .bio(u.getBio())
                .birthYear(u.getBirthYear())
                .avatarUrl(av)
                .isVip(Boolean.TRUE.equals(u.getIsVip()))
                .build();
    }

    /** 与 {@link #pageUsers} 查询条件一致：正常用户、非后台账号、未删除。 */
    private boolean isDirectoryListableUser(UserDomain u) {
        if (userStatus(u.getStatus()) != USER_STATUS_NORMAL) {
            return false;
        }
        Integer sr = u.getStaffRole();
        return sr != null && sr == 0;
    }

    private static int userStatus(Object status) {
        if (status instanceof Number n) {
            return n.intValue();
        }
        if (status instanceof String s) {
            return Integer.parseInt(s);
        }
        return 0;
    }
}
