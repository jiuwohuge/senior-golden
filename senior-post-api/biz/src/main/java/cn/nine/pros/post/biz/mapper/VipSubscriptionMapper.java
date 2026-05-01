package cn.nine.pros.post.biz.mapper;

import cn.nine.pros.post.biz.model.domain.VipSubscriptionDomain;
import org.apache.ibatis.annotations.Mapper;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;

/**
 * VIP订阅记录表 Mapper
 *
 * @author Administrator
 */
@Mapper
public interface VipSubscriptionMapper extends BaseMapper<VipSubscriptionDomain> {

}
