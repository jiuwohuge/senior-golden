package cn.nine.pros.post.biz.service.biz;

import cn.nine.pros.post.client.model.out.OssGetSignBatchResultVO;
import cn.nine.pros.post.client.model.out.OssPutSignResultVO;

import java.util.List;

public interface AppOssService {

    /**
     * @param scene    avatar | letter
     * @param ext      涓嶅惈鐐癸紝濡?jpg銆乸ng
     * @param contentType 鍙€夛紱涓嶄紶鍒欐寜鎵╁睍鍚嶆帹鏂?     */
    OssPutSignResultVO signPut(long userId, String scene, String ext, String contentType);

    /**
     * 涓哄凡瀛樺湪鐨?objectKey 鎵归噺绛惧彂 GET 棰勭鍚?URL锛圓pp锛氬舰鎬佹牎楠?+ 涓氬姟閴存潈锛夈€?     */
    OssGetSignBatchResultVO signGetBatch(long userId, List<String> objectKeys);

    /**
     * 绠＄悊绔崲绛撅細褰㈡€佹牎楠?+ staff 鐧藉悕鍗曪紝涓嶅仛鏄庝俊鐗?淇′欢绛変笟鍔＄粦瀹氥€?     */
    OssGetSignBatchResultVO signGetBatchStaff(List<String> objectKeys);
}

