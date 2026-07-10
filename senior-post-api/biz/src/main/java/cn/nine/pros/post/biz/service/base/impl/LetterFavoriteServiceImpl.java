package cn.nine.pros.post.biz.service.base.impl;

import cn.nine.pros.post.biz.mapper.LetterFavoriteMapper;
import cn.nine.pros.post.biz.model.domain.LetterFavoriteDomain;
import cn.nine.pros.post.biz.service.base.LetterFavoriteService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class LetterFavoriteServiceImpl extends ServiceImpl<LetterFavoriteMapper, LetterFavoriteDomain>
        implements LetterFavoriteService {

    @Override
    public long countForUser(Long userId) {
        if (userId == null) {
            return 0L;
        }
        return count(new LambdaQueryWrapper<LetterFavoriteDomain>()
                .eq(LetterFavoriteDomain::getUserId, userId)
                .eq(LetterFavoriteDomain::isDelFlag, false));
    }

    @Override
    public boolean isFavorite(Long userId, Long letterId) {
        if (userId == null || letterId == null) {
            return false;
        }
        return count(new LambdaQueryWrapper<LetterFavoriteDomain>()
                .eq(LetterFavoriteDomain::getUserId, userId)
                .eq(LetterFavoriteDomain::getLetterId, letterId)
                .eq(LetterFavoriteDomain::isDelFlag, false)) > 0;
    }

    @Override
    public List<LetterFavoriteDomain> listForUser(Long userId, int limit) {
        if (userId == null) {
            return List.of();
        }
        return list(new LambdaQueryWrapper<LetterFavoriteDomain>()
                .eq(LetterFavoriteDomain::getUserId, userId)
                .eq(LetterFavoriteDomain::isDelFlag, false)
                .orderByDesc(LetterFavoriteDomain::getCreatedAt)
                .last("LIMIT " + Math.max(1, limit)));
    }

    @Override
    public boolean addFavorite(Long userId, Long letterId) {
        if (userId == null || letterId == null) {
            return false;
        }
        if (isFavorite(userId, letterId)) {
            return true;
        }
        LetterFavoriteDomain row = new LetterFavoriteDomain();
        row.setUserId(userId);
        row.setLetterId(letterId);
        row.initAudit(userId);
        return save(row);
    }

    @Override
    public boolean removeFavorite(Long userId, Long letterId) {
        if (userId == null || letterId == null) {
            return false;
        }
        LetterFavoriteDomain row = getOne(new LambdaQueryWrapper<LetterFavoriteDomain>()
                .eq(LetterFavoriteDomain::getUserId, userId)
                .eq(LetterFavoriteDomain::getLetterId, letterId)
                .eq(LetterFavoriteDomain::isDelFlag, false)
                .last("LIMIT 1"));
        if (row == null) {
            return false;
        }
        row.setDelFlag(true);
        row.setUpdatedAt(java.time.LocalDateTime.now());
        row.setUpdatedBy(userId);
        return updateById(row);
    }
}
