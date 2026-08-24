import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Locale-aware display helpers. Dates follow the device locale
/// (`yMMMd` + time), not a China-only or US-only pattern.
abstract final class PostalFormat {
  static String date(BuildContext context, DateTime value) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMMMd(locale).format(value.toLocal());
  }

  static String dateTime(BuildContext context, DateTime value) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMMMd(locale).add_jm().format(value.toLocal());
  }

  static String percent(BuildContext context, double ratio) {
    final locale = Localizations.localeOf(context).toString();
    final format = NumberFormat.percentPattern(locale)
      ..maximumFractionDigits = 0
      ..minimumFractionDigits = 0;
    return format.format(ratio.clamp(0.0, 1.0));
  }
}
