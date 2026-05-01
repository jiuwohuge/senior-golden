package cn.nine.pros.post.biz.mapper;

import cn.nine.pros.post.biz.model.domain.StampTransactionDomain;
import org.apache.ibatis.annotations.Mapper;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;

/**
 * 邮票变更流水日志 Mapper
 *
 * @author Administrator
 */
@Mapper
public interface StampTransactionMapper extends BaseMapper<StampTransactionDomain> {

}
