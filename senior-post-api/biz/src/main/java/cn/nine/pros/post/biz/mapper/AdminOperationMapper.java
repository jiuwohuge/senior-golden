package cn.nine.pros.post.biz.mapper;

import cn.nine.pros.post.biz.model.domain.AdminOperationDomain;
import org.apache.ibatis.annotations.Mapper;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;

/**
 * 管理员操作日志表 Mapper
 *
 * @author Administrator
 */
@Mapper
public interface AdminOperationMapper extends BaseMapper<AdminOperationDomain> {

}
