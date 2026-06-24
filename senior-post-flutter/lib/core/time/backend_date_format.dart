import 'package:intl/intl.dart';

/// 后端 `LocalDate` JSON 格式（commons-web Jackson 约定）。
final DateFormat _backendLocalDate = DateFormat('MM-dd-yyyy');

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
    return DateTime.tryParse(s);
  }
}
