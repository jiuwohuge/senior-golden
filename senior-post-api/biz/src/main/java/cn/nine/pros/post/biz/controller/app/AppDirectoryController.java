package cn.nine.pros.post.biz.controller.app;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.commons.data.page.PageData;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.biz.service.app.AppDirectoryService;
import cn.nine.pros.post.client.api.app.AppDirectoryApi;
import cn.nine.pros.post.client.model.input.app.AppDirectoryPageInDto;
import cn.nine.pros.post.client.model.out.DirectoryUserItemVO;
import cn.nine.pros.post.client.model.out.InterestTagOptionVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class AppDirectoryController implements AppDirectoryApi {

    private final AppDirectoryService appDirectoryService;
    private final AppMessages appMessages;

    @Override
    public PageData<DirectoryUserItemVO> usersPaging(AppDirectoryPageInDto body) {
        Long uid = MyRequestContextHolder.userId();
        if (uid == null) {
            throw new BadRequestException(appMessages.get("app.error.notLoggedIn"));
        }
        return appDirectoryService.pageUsers(uid, body);
    }

    @Override
    public DirectoryUserItemVO getDirectoryUser(Long userId) {
        Long uid = MyRequestContextHolder.userId();
        if (uid == null) {
            throw new BadRequestException(appMessages.get("app.error.notLoggedIn"));
        }
        return appDirectoryService.getDirectoryUser(uid, userId);
    }

    @Override
    public List<String> listInterestTags(String lang) {
        Long uid = MyRequestContextHolder.userId();
        if (uid == null) {
            throw new BadRequestException(appMessages.get("app.error.notLoggedIn"));
        }
        return appDirectoryService.listInterestTagNames(lang);
    }

    @Override
    public List<InterestTagOptionVO> listInterestTagOptions(String lang) {
        Long uid = MyRequestContextHolder.userId();
        if (uid == null) {
            throw new BadRequestException(appMessages.get("app.error.notLoggedIn"));
        }
        return appDirectoryService.listInterestTagOptions(lang);
    }
}
