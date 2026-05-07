package cn.nine.pros.post.biz.service.app.impl;

import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.controller.app.AppPageHelper;
import cn.nine.pros.post.biz.model.domain.UserDomain;
import cn.nine.pros.post.biz.service.app.AppDirectoryService;
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

    private final UserService userService;

    @Override
    public PageData<DirectoryUserItemVO> pageUsers(long viewerUserId, AppDirectoryPageInDto body) {
        PageQuery pq = AppPageHelper.normalize(body == null ? null : body.getPage());
        LambdaQueryWrapper<UserDomain> qw = new LambdaQueryWrapper<UserDomain>()
                .eq(UserDomain::isDelFlag, false)
                .apply("status = 1")
                .eq(UserDomain::getStaffRole, 0)
                .ne(UserDomain::getId, viewerUserId)
                .orderByDesc(UserDomain::getCreatedAt);

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
            records.add(toVo(u));
        }
        return AppPageHelper.pageData(pq, p, records);
    }

    private static DirectoryUserItemVO toVo(UserDomain u) {
        return DirectoryUserItemVO.builder()
                .id(u.getId())
                .nickname(u.getNickname())
                .countryCode(u.getCountryCode())
                .bio(u.getBio())
                .birthYear(u.getBirthYear())
                .avatarUrl(u.getAvatarUrl())
                .isVip(Boolean.TRUE.equals(u.getIsVip()))
                .build();
    }
}
