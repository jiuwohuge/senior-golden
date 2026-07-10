package cn.nine.pros.post.biz.service.biz;

import cn.nine.pros.post.client.model.out.DirectoryUserItemVO;

import java.util.List;

public interface AppRecommendBizService {

    List<DirectoryUserItemVO> listTodayRecommendations(long viewerUserId);
}
