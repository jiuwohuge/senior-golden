package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import cn.nine.pros.post.biz.mapper.UserDeviceMapper;
import cn.nine.pros.post.biz.model.domain.UserDeviceDomain;
import cn.nine.pros.post.biz.model.mapstruct.UserDeviceMapstruct;
import cn.nine.pros.post.biz.service.base.UserDeviceService;
import cn.nine.pros.post.client.model.db.UserDeviceDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 用户设备记录表（用于风控/拉黑/防刷） ServiceImpl
 *
 * @author Administrator
 */
@Service
public class UserDeviceServiceImpl extends ServiceImpl<UserDeviceMapper, UserDeviceDomain>
        implements UserDeviceService {

    @Autowired
    private UserDeviceMapstruct userDeviceMapstruct;

    @Override
    public void upsert(UserDeviceDTO userDeviceDTO) {
        Long id = userDeviceDTO.getId();
        if (id == null) {
            UserDeviceDomain domain = userDeviceMapstruct.toDomain(userDeviceDTO);
            domain.initAudit(MyRequestContextHolder.userId());
            save(domain);
            return;
        }
        UserDeviceDomain domain = userDeviceMapstruct.toDomain(userDeviceDTO);
        domain.setId(id);
        domain.setUpdatedAt(LocalDateTime.now());
        domain.setUpdatedBy(MyRequestContextHolder.userId());
        updateById(domain);
    }

    @Override
    public UserDeviceDTO findById(Long id) {
        return userDeviceMapstruct.toDTO(getById(id));
    }

    @Override
    public void delByIds(List<Long> ids) {
        UserDeviceDomain userDeviceDomain = new UserDeviceDomain();
        userDeviceDomain.setDelFlag(true);
        userDeviceDomain.setUpdatedAt(LocalDateTime.now());
        update(userDeviceDomain, new LambdaQueryWrapper<UserDeviceDomain>()
                .in(UserDeviceDomain::getId, ids));
    }

}