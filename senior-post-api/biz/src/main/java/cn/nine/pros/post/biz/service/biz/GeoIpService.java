package cn.nine.pros.post.biz.service.biz;

import cn.nine.pros.post.biz.service.biz.support.GeoIpLookup;

/**
 * IP → 国家/城市/经纬度。失败时返回空结果，不抛异常。
 */
public interface GeoIpService {

    GeoIpLookup resolve(String ip);
}
