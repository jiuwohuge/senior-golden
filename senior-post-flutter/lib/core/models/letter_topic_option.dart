/// 与后端 `LetterTopicOptionVO` 对齐：写信主题邮票，id 由 bootstrap 下发。
class LetterTopicOption {
  const LetterTopicOption({
    required this.id,
    required this.code,
    required this.title,
  });

  final int id;
  final String code;
  final String title;

  factory LetterTopicOption.fromJson(Map<String, dynamic> m) {
    return LetterTopicOption(
      id: (m['id'] as num?)?.toInt() ?? 0,
      code: ((m['code'] as String?) ?? '').trim(),
      title: ((m['title'] as String?) ?? '').trim(),
    );
  }
}
