package cn.nine.pros.post.biz.mapper;

import cn.nine.pros.post.biz.model.domain.PaymentWebhookEventDomain;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface PaymentWebhookEventMapper extends BaseMapper<PaymentWebhookEventDomain> {
}
