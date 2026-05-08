package cn.nine.pros.post.biz.service.app;

import cn.nine.pros.post.client.model.out.OssGetSignBatchResultVO;
import cn.nine.pros.post.client.model.out.OssPutSignResultVO;

import java.util.List;

public interface AppOssService {

    /**
     * @param scene    postcard | avatar | letter
     * @param ext      不含点，如 jpg、png
     * @param contentType 可选；不传则按扩展名推断
     */
    OssPutSignResultVO signPut(long userId, String scene, String ext, String contentType);

    /**
     * 为已存在的 objectKey 批量签发 GET 预签名 URL（App：形态校验 + 业务鉴权）。
     */
    OssGetSignBatchResultVO signGetBatch(long userId, List<String> objectKeys);

    /**
     * 管理端换签：形态校验 + staff 白名单，不做明信片/信件等业务绑定。
     */
    OssGetSignBatchResultVO signGetBatchStaff(List<String> objectKeys);
}
