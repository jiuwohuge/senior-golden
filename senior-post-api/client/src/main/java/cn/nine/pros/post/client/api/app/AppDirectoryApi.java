package cn.nine.pros.post.client.api.app;

import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.client.model.input.app.AppDirectoryPageInDto;
import cn.nine.pros.post.client.model.out.DirectoryUserItemVO;

/**
 * App 通信名录。具体 HTTP 映射见 {@code AppDirectoryController}。
 */
public interface AppDirectoryApi {

    PageData<DirectoryUserItemVO> usersPaging(AppDirectoryPageInDto body);

    DirectoryUserItemVO getDirectoryUser(Long userId);
}
