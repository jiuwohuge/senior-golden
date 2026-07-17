import 'package:flutter/material.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/bootstrap/app_bootstrap.dart';
import 'postal_country_seal.dart';

/// 半屏可搜索国家选择；App 仅维护国家，不展示「地区」。
///
/// 主题 [BottomSheetThemeData.showDragHandle] 已为 true，勿再画自定义横条。
/// 搜索框 Controller 由 sheet 内部 State 持有并在 [State.dispose] 释放，
/// 避免外层在关闭动画未结束时 dispose 触发 `_dependents.isEmpty`。
Future<String?> showPostalCountryPickerSheet({
  required BuildContext context,
  required AppLocalizations l10n,
  required List<CountryItem> countries,
  required String languageCode,
  String? selectedCode,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: PostalTokens.paperEnvelope,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (ctx) {
      return _PostalCountryPickerBody(
        l10n: l10n,
        countries: countries,
        languageCode: languageCode,
        selectedCode: selectedCode,
      );
    },
  );
}

class _PostalCountryPickerBody extends StatefulWidget {
  const _PostalCountryPickerBody({
    required this.l10n,
    required this.countries,
    required this.languageCode,
    required this.selectedCode,
  });

  final AppLocalizations l10n;
  final List<CountryItem> countries;
  final String languageCode;
  final String? selectedCode;

  @override
  State<_PostalCountryPickerBody> createState() =>
      _PostalCountryPickerBodyState();
}

class _PostalCountryPickerBodyState extends State<_PostalCountryPickerBody> {
  late final TextEditingController _query;

  @override
  void initState() {
    super.initState();
    _query = TextEditingController();
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.text.trim().toLowerCase();
    final filtered = widget.countries.where((c) {
      if (q.isEmpty) return true;
      final name = c.displayName(widget.languageCode).toLowerCase();
      return name.contains(q) ||
          c.code.toLowerCase().contains(q) ||
          c.nameEn.toLowerCase().contains(q) ||
          c.nameZh.toLowerCase().contains(q);
    }).toList();

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.62,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.l10n.authRegisterSummaryCountry,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: PostalTokens.inkNavy,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _query,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: widget.l10n.authRegisterCountrySearchHint,
                  prefixIcon: const Icon(
                    Icons.search,
                    color: PostalTokens.postboxGreen,
                  ),
                  filled: true,
                  fillColor: PostalTokens.paperCream,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: PostalTokens.kraftBrownMuted.withValues(
                        alpha: 0.9,
                      ),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: PostalTokens.kraftBrownMuted.withValues(
                        alpha: 0.9,
                      ),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: PostalTokens.postboxGreen,
                      width: 1.4,
                    ),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          '—',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: PostalTokens.inkTertiary),
                        ),
                      )
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: PostalTokens.perforationLine.withValues(
                            alpha: 0.7,
                          ),
                        ),
                        itemBuilder: (_, i) {
                          final c = filtered[i];
                          final selected = c.code == widget.selectedCode;
                          final code = c.code.trim().toUpperCase();
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4,
                            ),
                            // 列表用深绿字号码，避免朱红邮戳看起来像错误附件。
                            leading: SizedBox(
                              width: 36,
                              child: Text(
                                code,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      color: PostalTokens.postboxGreen,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.4,
                                    ),
                              ),
                            ),
                            title: Text(
                              c.displayName(widget.languageCode),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: PostalTokens.inkNavy,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                            ),
                            trailing: selected
                                ? const Icon(
                                    Icons.check_circle,
                                    color: PostalTokens.postboxGreen,
                                  )
                                : null,
                            onTap: () => Navigator.pop(context, c.code),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 注册确认 / 资料编辑用的紧凑国家选择值：内容自适应，无满宽灰底输入框。
class PostalCountrySelectChip extends StatelessWidget {
  const PostalCountrySelectChip({
    super.key,
    required this.countryCode,
    required this.countryName,
    required this.onTap,
    this.enabled = true,
  });

  final String? countryCode;
  final String countryName;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final code = (countryCode ?? '').trim().toUpperCase();
    final name = countryName.trim().isEmpty ? '—' : countryName.trim();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          decoration: BoxDecoration(
            color: PostalTokens.paperCream.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: PostalTokens.postboxGreen.withValues(alpha: 0.35),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 10, 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (code.isNotEmpty) ...[
                  PostalCountrySeal(
                    countryCode: code,
                    compact: true,
                    color: PostalTokens.postboxGreen,
                  ),
                  const SizedBox(width: 8),
                ],
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 148),
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: PostalTokens.inkNavy,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.expand_more_rounded,
                  size: 20,
                  color: enabled
                      ? PostalTokens.postboxGreen
                      : PostalTokens.inkTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
