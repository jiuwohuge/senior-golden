package cn.nine.pros.post.biz.service.base.impl;




import cn.nine.pros.post.biz.model.domain.AppFeedbackDomain;

import cn.nine.pros.post.biz.service.base.AppFeedbackService;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.nine.pros.post.biz.mapper.AppFeedbackMapper;

import org.springframework.stereotype.Service;



@Service("baseAppFeedbackService")
public class AppFeedbackServiceImpl extends ServiceImpl<AppFeedbackMapper, AppFeedbackDomain>

        implements AppFeedbackService {

}

