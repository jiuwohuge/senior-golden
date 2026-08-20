package cn.nine.pros.post.biz.controller.admin;

import cn.nine.pros.post.biz.service.biz.admin.AdminPostOfficeBizService;
import cn.nine.pros.post.client.api.admin.AdminPostOfficeApi;
import cn.nine.pros.post.client.model.out.AdminPostOfficePoolStatusVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class AdminPostOfficeController implements AdminPostOfficeApi {

    private final AdminPostOfficeBizService adminPostOfficeBizService;

    @Override
    public AdminPostOfficePoolStatusVO poolStatus() {
        return adminPostOfficeBizService.poolStatus();
    }
}
