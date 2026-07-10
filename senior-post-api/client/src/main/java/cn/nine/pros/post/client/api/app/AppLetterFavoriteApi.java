package cn.nine.pros.post.client.api.app;

import cn.nine.pros.post.client.common.constant.AppServiceDefine;
import cn.nine.pros.post.client.model.out.MailboxLetterItemVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;

@Tag(name = "App-信件收藏")
@RequestMapping(AppServiceDefine.SERVER_PREFIX + "/letters")
public interface AppLetterFavoriteApi {

    @Operation(summary = "收藏信件")
    @PostMapping("/{id}/favorite")
    void favorite(@PathVariable("id") Long id);

    @Operation(summary = "取消收藏")
    @DeleteMapping("/{id}/favorite")
    void unfavorite(@PathVariable("id") Long id);

    @Operation(summary = "收藏列表")
    @GetMapping("/favorites")
    List<MailboxLetterItemVO> listFavorites();
}
