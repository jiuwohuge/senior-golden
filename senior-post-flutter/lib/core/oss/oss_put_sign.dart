/// 与后端 [OssPutSignResultVO] 对齐。
class OssPutSignResult {
  const OssPutSignResult({
    required this.putUrl,
    required this.objectKey,
    required this.contentType,
    required this.expireAtEpochMillis,
    this.readUrl,
  });

  factory OssPutSignResult.fromJson(Map<String, dynamic> json) {
    return OssPutSignResult(
      putUrl: (json['putUrl'] as String?) ?? '',
      objectKey: (json['objectKey'] as String?) ?? '',
      contentType:
          (json['contentType'] as String?) ?? 'application/octet-stream',
      expireAtEpochMillis: (json['expireAtEpochMillis'] as num?)?.toInt() ?? 0,
      readUrl: json['readUrl'] as String?,
    );
  }

  final String putUrl;
  final String objectKey;
  final String contentType;
  final int expireAtEpochMillis;
  final String? readUrl;
}
