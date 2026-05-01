package cn.nine.pros.post.client.common.constant;

public interface AppServiceDefine {

    /** 移动端 / 对外 App 接口前缀（可与 AES 加解密策略绑定，见 application.yml） */
    String SERVER_PREFIX = "/api";

    /** 管理后台对内接口前缀：与 App 共用统一响应与 85xx，生产环境不做请求解密/响应加密 */
    String WEBAPI_PREFIX = "/webapi";

    String APP_SERVICE_NAME = "senior-post-api-${spring.profiles.active}";

}
