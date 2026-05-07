package cn.nine.pros.post.biz.service.app;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.client.model.input.app.AppDirectoryPageInDto;
import cn.nine.pros.post.client.model.out.DirectoryUserItemVO;

public interface AppDirectoryService {

    PageData<DirectoryUserItemVO> pageUsers(long viewerUserId, AppDirectoryPageInDto body);
}
