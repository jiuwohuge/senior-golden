import 'package:flutter/material.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

List<int> buildBirthYearChoices({
  required int minRegisterAge,
  int maxRegisterAgeYears = 110,
  DateTime? now,
}) {
  final currentYear = (now ?? DateTime.now()).year;
  final minYear = currentYear - maxRegisterAgeYears;
  final maxYear = currentYear - minRegisterAge;
  if (maxYear < minYear) {
    return const <int>[];
  }
  return [for (var year = maxYear; year >= minYear; year--) year];
}

Future<int?> showBirthYearPickerSheet(
  BuildContext context, {
  required AppLocalizations l10n,
  required List<int> years,
}) {
  if (years.isEmpty) {
    return Future<int?>.value(null);
  }
  final nowYear = DateTime.now().year;
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        minChildSize: 0.35,
        maxChildSize: 0.9,
        builder: (_, scrollController) {
          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Text(
                    l10n.authBirthYearSheetTitle,
                    style: Theme.of(ctx).textTheme.titleLarge,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: years.length,
                    itemBuilder: (_, index) {
                      final year = years[index];
                      final age = nowYear - year;
                      return ListTile(
                        title: Text(l10n.authBirthYearFormat('$year', '$age')),
                        onTap: () => Navigator.pop(ctx, year),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
