package cn.nine.pros.post.biz.service.biz;

import cn.nine.pros.post.client.model.out.MailboxLetterItemVO;

import java.util.List;

public interface AppLetterFavoriteBizService {

    void favorite(long userId, long letterId);

    void unfavorite(long userId, long letterId);

    List<MailboxLetterItemVO> listFavorites(long userId);
}
