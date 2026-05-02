package cn.nine.pros.post.biz.service.app;

import cn.nine.commons.data.page.PageData;
import cn.nine.commons.data.page.PageQuery;
import cn.nine.pros.post.client.model.db.StampTransactionDTO;
import cn.nine.pros.post.client.model.out.AppStampBalanceVO;

public interface AppStampsService {

    AppStampBalanceVO balance(long userId);

    PageData<StampTransactionDTO> ledgerPage(long userId, PageQuery pageQuery);
}
