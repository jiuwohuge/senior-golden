package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.pros.post.biz.mapper.PostcardCommentLikeMapper;
import cn.nine.pros.post.biz.model.domain.PostcardCommentLikeDomain;
import cn.nine.pros.post.biz.service.base.PostcardCommentLikeService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;

import java.util.Collection;
import java.util.Collections;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class PostcardCommentLikeServiceImpl extends ServiceImpl<PostcardCommentLikeMapper, PostcardCommentLikeDomain>
        implements PostcardCommentLikeService {

    @Override
    public Set<Long> findLikedCommentIds(long userId, Collection<Long> commentIds) {
        if (CollectionUtils.isEmpty(commentIds)) {
            return Collections.emptySet();
        }
        return list(new LambdaQueryWrapper<PostcardCommentLikeDomain>()
                .eq(PostcardCommentLikeDomain::getUserId, userId)
                .in(PostcardCommentLikeDomain::getCommentId, commentIds)
                .eq(PostcardCommentLikeDomain::isDelFlag, false))
                .stream()
                .map(PostcardCommentLikeDomain::getCommentId)
                .collect(Collectors.toSet());
    }
}
