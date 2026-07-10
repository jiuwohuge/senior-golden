package cn.nine.pros.post.biz.service.base;

import cn.nine.pros.post.biz.model.domain.LetterFavoriteDomain;
import com.baomidou.mybatisplus.extension.service.IService;

import java.util.List;

public interface LetterFavoriteService extends IService<LetterFavoriteDomain> {

    long countForUser(Long userId);

    boolean isFavorite(Long userId, Long letterId);

    List<LetterFavoriteDomain> listForUser(Long userId, int limit);

    boolean addFavorite(Long userId, Long letterId);

    boolean removeFavorite(Long userId, Long letterId);
}
