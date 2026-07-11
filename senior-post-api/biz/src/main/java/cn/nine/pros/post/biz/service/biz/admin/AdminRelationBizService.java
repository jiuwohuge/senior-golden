package cn.nine.pros.post.biz.service.biz.admin;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.unchecked.BusinessException;
import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.biz.controller.admin.AdminPageHelper;
import cn.nine.pros.post.biz.model.domain.FriendshipDomain;
import cn.nine.pros.post.biz.service.base.FriendshipService;
import cn.nine.pros.post.biz.service.base.LetterService;
import cn.nine.pros.post.biz.service.biz.admin.support.AdminOperationRecorder;
import cn.nine.pros.post.client.model.input.admin.AdminPenpalQueryInDto;
import cn.nine.pros.post.client.model.out.AdminPenpalItemVO;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 管理端笔友关系：分页与强制解除。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AdminRelationBizService {

    private final FriendshipService friendshipService;
    private final LetterService letterService;
    private final AdminOperationRecorder adminOperationRecorder;

    /**
     * 活跃笔友分页，附带往来信件数。
     */
    public PageData<AdminPenpalItemVO> pagingPenpal(AdminPenpalQueryInDto body) {
        PageQuery pageQuery = AdminPageHelper.normalize(body.getPage());
        Page<FriendshipDomain> p = friendshipService.pageForAdmin(
                pageQuery, body.getUserId(), body.getPeerId(),
                body.getCreatedFrom(), body.getCreatedTo());
        List<AdminPenpalItemVO> list = p.getRecords().stream().map(this::toVo).collect(Collectors.toList());
        return AdminPageHelper.pageData(pageQuery, p, list);
    }

    /**
     * 强制解除笔友关系。
     */
    @Transactional(rollbackFor = Exception.class)
    public void dissolvePenpal(Long id) {
        if (id == null) {
            throw new BusinessException("friendship id required");
        }
        FriendshipDomain row = friendshipService.getById(id);
        if (row == null || row.isDelFlag()) {
            throw new BusinessException("friendship not found");
        }
        if (!friendshipService.deactivateById(id, MyRequestContextHolder.userId())) {
            throw new BusinessException("friendship dissolve failed");
        }
        adminOperationRecorder.record("penpal.dissolve", "friendship", id,
                "userA=" + row.getUserLow() + ",userB=" + row.getUserHigh());
        log.info("admin dissolve penpal, friendshipId={}, userLow={}, userHigh={}",
                id, row.getUserLow(), row.getUserHigh());
    }

    private AdminPenpalItemVO toVo(FriendshipDomain f) {
        long letterCount = 0L;
        if (f.getUserLow() != null && f.getUserHigh() != null) {
            letterCount = letterService.countExchangeBetween(f.getUserLow(), f.getUserHigh());
        }
        return AdminPenpalItemVO.builder()
                .id(f.getId())
                .userA(f.getUserLow())
                .userB(f.getUserHigh())
                .createdAt(f.getCreatedAt())
                .letterCount(letterCount)
                .build();
    }
}
