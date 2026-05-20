/// 与 Dio 请求头 `versionCode`、后端公告筛选一致。
const String kApiVersionCode = String.fromEnvironment(
  'API_VERSION_CODE',
  defaultValue: '2',
);

int apiVersionCodeInt() => int.tryParse(kApiVersionCode) ?? 2;
