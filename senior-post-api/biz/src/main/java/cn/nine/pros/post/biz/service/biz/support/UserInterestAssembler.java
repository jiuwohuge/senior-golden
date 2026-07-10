package cn.nine.pros.post.biz.service.biz.support;

import cn.nine.pros.post.biz.model.domain.TagDomain;
import cn.nine.pros.post.biz.model.domain.UserTagDomain;
import cn.nine.pros.post.biz.service.base.TagService;
import cn.nine.pros.post.biz.service.base.UserTagService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 从 {@code bu_user_tag} + {@code sys_tag} 组装用户兴趣列表（排序与资料 VO 一致）。
 */
@Component
@RequiredArgsConstructor
public class UserInterestAssembler {

    private final UserTagService userTagService;
    private final TagService tagService;

    public record Payload(List<Integer> ids, List<String> names) {}

    public Payload loadForUser(long userId) {
        List<Integer> tagIds = userTagService.list(new LambdaQueryWrapper<UserTagDomain>()
                        .eq(UserTagDomain::getUserId, userId)
                        .eq(UserTagDomain::isDelFlag, false))
                .stream()
                .map(UserTagDomain::getTagId)
                .collect(Collectors.toList());
        if (tagIds.isEmpty()) {
            return new Payload(List.of(), List.of());
        }
        List<TagDomain> tags = tagService.listByIds(tagIds);
        tags.sort((a, b) -> {
            int sa = a.getSortOrder() == null ? 0 : a.getSortOrder();
            int sb = b.getSortOrder() == null ? 0 : b.getSortOrder();
            if (sa != sb) {
                return Integer.compare(sa, sb);
            }
            return Integer.compare(
                    a.getId() == null ? 0 : a.getId(),
                    b.getId() == null ? 0 : b.getId());
        });
        List<Integer> orderedIds = tags.stream()
                .map(TagDomain::getId)
                .collect(Collectors.toList());
        List<String> names = tags.stream()
                .map(TagDomain::getTagName)
                .collect(Collectors.toList());
        return new Payload(orderedIds, names);
    }
}
