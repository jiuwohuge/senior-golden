package cn.nine.pros.post.biz.service.app;

import cn.nine.commons.basic.context.MyRequestContextHolder;
import cn.nine.commons.basic.context.RequestContext;
import cn.nine.commons.basic.exception.BadRequestException;
import cn.nine.commons.basic.model.TokenInfo;
import cn.nine.commons.basic.util.TokenResolver;
import cn.nine.commons.web.filter.adapter.RedisCacheAdapter;
import cn.nine.pros.post.biz.i18n.AppMessages;
import cn.nine.pros.post.client.common.constant.RedisConstant;
import com.alibaba.fastjson2.JSON;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 * App / 管理端共用：subject 为 {@code bu_user.id}，与框架验签使用同一 {@code senior-post.app.jwt.secret}。
 */
@Service
public class AppJwtService {

    @Autowired
    private RedisCacheAdapter redisCacheAdapter;

    @Autowired
    private AppMessages appMessages;

    public String createToken(long userId) {
        if (userId <= 0) {
            throw new BadRequestException(appMessages.get("app.error.jwt.invalidUser"));
        }
        return buildToken(userId);
    }

    private String buildToken(long subjectNumeric) {
        TokenInfo tokenInfo = new TokenInfo();
        tokenInfo.setApp(RedisConstant.PROJECT);
        tokenInfo.setUserId(subjectNumeric);
        tokenInfo.setTimestampVersion(System.currentTimeMillis());
        String token = TokenResolver.createToken(JSON.toJSONString(tokenInfo), TokenResolver.MONTH_SECOND);
        //填充上下文，并加入到缓存
        fillUpContent(token, tokenInfo);
        return token;
    }

    private void fillUpContent(String token, TokenInfo tokenInfo) {
        RequestContext context = MyRequestContextHolder.getContext();
        if (null != context) {
            context.setTokenInfo(tokenInfo);
        }
        redisCacheAdapter.addCache(token);
    }

}
