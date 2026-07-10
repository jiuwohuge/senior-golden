package cn.nine.pros.post.biz.service.biz;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.client.model.input.app.AppDirectoryPageInDto;
import cn.nine.pros.post.client.model.out.DirectoryUserItemVO;
import cn.nine.pros.post.client.model.out.InterestTagOptionVO;

import java.util.List;

public interface AppDirectoryService {

    PageData<DirectoryUserItemVO> pageUsers(long viewerUserId, AppDirectoryPageInDto body);

    DirectoryUserItemVO getDirectoryUser(long viewerUserId, long targetUserId);

    List<String> listInterestTagNames(String langCode);

    List<InterestTagOptionVO> listInterestTagOptions(String langCode);
}
