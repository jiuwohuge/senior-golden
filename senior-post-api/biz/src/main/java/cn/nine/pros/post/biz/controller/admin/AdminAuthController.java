package cn.nine.pros.post.biz.controller.admin;

import cn.nine.pros.post.biz.service.biz.admin.AdminAuthBizService;
import cn.nine.pros.post.client.api.admin.AdminAuthApi;
import cn.nine.pros.post.client.model.db.UserDTO;
import cn.nine.pros.post.client.model.input.admin.LoginInDto;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequiredArgsConstructor
public class AdminAuthController implements AdminAuthApi {

    private final AdminAuthBizService adminAuthBizService;

    @Override
    public Map<String, Object> login(LoginInDto loginReq) {
        return adminAuthBizService.login(loginReq);
    }

    @Override
    public void logout() {
        adminAuthBizService.logout();
    }

    @Override
    public UserDTO getCurrentAdmin() {
        return adminAuthBizService.getCurrentAdmin();
    }
}
