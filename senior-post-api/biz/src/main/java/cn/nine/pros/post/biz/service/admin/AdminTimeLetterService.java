package cn.nine.pros.post.biz.service.admin;

import cn.nine.pros.post.biz.model.domain.TimeLetterDomain;
import cn.nine.pros.post.client.model.db.TimeLetterDTO;

public interface AdminTimeLetterService {

    TimeLetterDTO getDetail(long id);

    void takedown(long id, String reason);

    TimeLetterDTO toDto(TimeLetterDomain d);
}
