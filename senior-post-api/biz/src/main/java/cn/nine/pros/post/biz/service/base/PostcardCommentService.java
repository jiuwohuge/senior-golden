package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.PostcardCommentDomain;
import com.baomidou.mybatisplus.extension.service.IService;
import cn.nine.pros.post.client.model.db.PostcardCommentDTO;

import java.util.List;

/**
 * 明信片评论表 Service
 *
 * @author Administrator
 */
public interface PostcardCommentService extends IService<PostcardCommentDomain> {

    void upsert(PostcardCommentDTO postcardCommentDTO);

    PostcardCommentDTO findById(Long id);

    void delByIds(List<Long> ids);

}