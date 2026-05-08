/// 与后端 `InterestTagOptionVO` 对齐。
class InterestTagOption {
  const InterestTagOption({required this.id, required this.tagName, this.langCode});

  final int id;
  final String tagName;
  final String? langCode;

  factory InterestTagOption.fromJson(Map<String, dynamic> m) {
    return InterestTagOption(
      id: (m['id'] as num?)?.toInt() ?? 0,
      tagName: ((m['tagName'] as String?) ?? '').trim(),
      langCode: m['langCode'] as String?,
    );
  }
}
