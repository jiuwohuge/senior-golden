package cn.nine.pros.post.biz.service.biz;

import cn.nine.pros.post.client.model.input.app.CommerceMockPurchaseInDto;
import cn.nine.pros.post.client.model.out.CommerceEntitlementVO;
import cn.nine.pros.post.client.model.out.CommerceProductVO;

import java.util.List;

/**
 * §16 商业 MVP：目录、权益与模拟购买。
 */
public interface AppCommerceBizService {

    List<CommerceProductVO> catalog(long userId);

    List<CommerceEntitlementVO> entitlements(long userId);

    CommerceEntitlementVO mockPurchase(long userId, CommerceMockPurchaseInDto body);

    /** 发信前校验 skin/font/template 权益；default 或空视为免费。 */
    void assertLetterContentEntitlements(long userId, String skinId, String fontId, String templateId);
}
