package cn.nine.pros.post.biz.service.app;

import cn.nine.pros.post.client.model.out.OssPutSignResultVO;

public interface AppOssService {

    /**
     * @param scene    postcard | avatar | letter
     * @param ext      不含点，如 jpg、png
     * @param contentType 可选；不传则按扩展名推断
     */
    OssPutSignResultVO signPut(long userId, String scene, String ext, String contentType);
}
