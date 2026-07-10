package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.LetterDomain;
import com.baomidou.mybatisplus.extension.service.IService;
import cn.nine.pros.post.client.model.db.LetterDTO;

import java.util.List;


/**
 * 信件表（挂号信/平邮） Service
 *
 * @author Administrator
 */
public interface LetterService extends IService<LetterDomain> {

    void upsert(LetterDTO letterDTO);

    LetterDTO findById(Long id);

    void delByIds(List<Long> ids);

    long countPeerLetterReferencingContent(long viewerUserId, long ownerUserId, List<String> variants);

}