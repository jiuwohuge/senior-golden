import 'package:intl/intl.dart';

/// 后端 Jackson `LocalDate`：ISO `yyyy-MM-dd`。
final DateFormat _backendLocalDate = DateFormat('yyyy-MM-dd');

/// 历史误用格式，仅解析兼容。
final DateFormat _legacyUsLocalDate = DateFormat('MM-dd-yyyy');

String formatBackendLocalDate(DateTime date) {
  return _backendLocalDate.format(DateTime(date.year, date.month, date.day));
}

DateTime? parseBackendLocalDate(Object? raw) {
  if (raw == null) return null;
  if (raw is! String) return null;
  final s = raw.trim();
  if (s.isEmpty) return null;
  try {
    return _backendLocalDate.parseStrict(s);
  } catch (_) {
    try {
      return _legacyUsLocalDate.parseStrict(s);
    } catch (_) {
      return DateTime.tryParse(s);
    }
  }
}

