package cn.nine.pros.post.biz.service.biz;

import cn.nine.pros.post.client.model.out.AppPostOfficeHomeVO;
import cn.nine.pros.post.client.model.out.PostOfficeInTransitItemVO;
import cn.nine.pros.post.client.model.out.PostOfficeRelationMessageVO;

import java.util.List;

public interface AppPostOfficeService {

    AppPostOfficeHomeVO home(long userId);

    List<PostOfficeRelationMessageVO> listRelationMessages(long userId);

    List<PostOfficeInTransitItemVO> listInTransit(long userId);
}
