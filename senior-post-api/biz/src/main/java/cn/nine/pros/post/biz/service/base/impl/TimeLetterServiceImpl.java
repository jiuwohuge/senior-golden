package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.pros.post.biz.model.domain.TimeLetterDomain;
import cn.nine.pros.post.biz.service.base.TimeLetterService;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.nine.pros.post.biz.mapper.TimeLetterMapper;
import org.springframework.stereotype.Service;

@Service
public class TimeLetterServiceImpl extends ServiceImpl<TimeLetterMapper, TimeLetterDomain>
        implements TimeLetterService {
}
