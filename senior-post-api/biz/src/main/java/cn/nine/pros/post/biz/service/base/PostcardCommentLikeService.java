package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.PostcardCommentLikeDomain;
import com.baomidou.mybatisplus.extension.service.IService;

import java.util.Collection;
import java.util.Set;

public interface PostcardCommentLikeService extends IService<PostcardCommentLikeDomain> {

    /** 当前用户对一批评论的已点赞 ID 集合 */
    Set<Long> findLikedCommentIds(long userId, Collection<Long> commentIds);
}
