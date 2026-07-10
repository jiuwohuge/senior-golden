package cn.nine.pros.post.biz.service.base.impl;




import cn.nine.pros.post.biz.model.domain.PasswordResetTokenDomain;

import cn.nine.pros.post.biz.service.base.PasswordResetTokenService;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.nine.pros.post.biz.mapper.PasswordResetTokenMapper;

import org.springframework.stereotype.Service;



@Service

public class PasswordResetTokenServiceImpl extends ServiceImpl<PasswordResetTokenMapper, PasswordResetTokenDomain>

        implements PasswordResetTokenService {

}

