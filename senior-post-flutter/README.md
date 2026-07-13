# senior_post_flutter

Senior Post — 欧美邮政社交 App（Flutter 客户端）。

**正式上线渠道：Android。** Flutter Web 仅用于本地多开联调（避免多开 Android 模拟器占内存）。

## 本地运行

### Android（正式目标）

```powershell
flutter run -d <deviceId>
# 或：powershell -File .\scripts\flutter-run-timed.ps1
```

默认 API：`http://10.0.2.2/backend`（模拟器访问宿主机 nginx）。

### Web（多账号联调）

前置：根目录 `docker compose` 已起 API（建议经 nginx `:80/backend`）。

```powershell
# Chrome
powershell -File .\scripts\flutter-run-web.ps1

# Edge
powershell -File .\scripts\flutter-run-web.ps1 -DeviceId edge

# 直连 API 容器（绕过 nginx）
powershell -File .\scripts\flutter-run-web.ps1 -ApiBaseUrl "http://localhost:9011/backend"
```

默认 API：`http://localhost/backend`。  
多开方式：额外 Chrome 访客/无痕窗口，或 `flutter run -d chrome` / `-d edge` 各起一份。

Web 下跳过：FCM 推送、Google 登录、注册页定位。  
请求头 `deviceId` 在 Web 上报 `Android`（复用 commons-security AES 门槛；勿改回 `Web`，否则登录密文无法解密）。

## API Base URL

```text
--dart-define=API_BASE_URL=...   # 最高优先级
Debug 登录页长按覆盖               # 持久化到本地
平台默认                            # Android 模拟器 / Web 见上
```
