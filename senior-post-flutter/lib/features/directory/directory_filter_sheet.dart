import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/postal_tokens.dart';
import '../../core/bootstrap/app_bootstrap.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/postal/postal.dart';
import 'directory_providers.dart';
import 'directory_remote.dart';

/// 筛选「兴趣」选项：`value` 为 `sys_tag.tag_name`，提交给 `interestNames`。
class DirectoryFilterTagOption {
  const DirectoryFilterTagOption({required this.value, required this.label});

  final String value;
  final String label;
}

final directoryFilterTagOptionsProvider =
    FutureProvider.family<List<DirectoryFilterTagOption>, String>((
      ref,
      lang,
    ) async {
      final options = await ref
          .read(directoryRemoteProvider)
          .listInterestTagOptions(lang: lang);
      return options
          .map(
            (o) => DirectoryFilterTagOption(value: o.tagName, label: o.tagName),
          )
          .toList();
    });

class DirectoryFilterSheet extends ConsumerStatefulWidget {
  const DirectoryFilterSheet({super.key});

  @override
  ConsumerState<DirectoryFilterSheet> createState() =>
      _DirectoryFilterSheetState();
}

class _DirectoryFilterSheetState extends ConsumerState<DirectoryFilterSheet> {
  String? _countryCode;
  int _minAge = 45;
  int _maxAge = 80;
  final Set<String> _interests = {};
  final Set<int> _genders = {};
  String _sort = 'DEFAULT';

  @override
  void initState() {
    super.initState();
    final f = ref.read(directoryFilterProvider);
    _countryCode = f.countryCode;
    _minAge = f.minAge;
    _maxAge = f.maxAge;
    _interests.addAll(f.interests);
    _genders.addAll(f.genders.where((g) => g == 1 || g == 2));
    _sort = f.sort;
  }

  /// 筛选分组：标题 + 说明 + 控件，避免下一组芯片被误读为上一组子项。
  Widget _filterFieldGroup({
    required BuildContext context,
    required String title,
    String? hint,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: theme.textTheme.titleSmall),
        if (hint != null && hint.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            hint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: PostalTokens.inkSecondary,
            ),
          ),
        ],
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  /// [Wrap] 内单颗芯片若「最小宽度」超过父级可用宽度会横向溢出；同时下拉未 `isExpanded` 时
  /// 会以「最宽菜单项」为最小宽度，长国家名同样会 RIGHT OVERFLOW，把下方 Slider 挤出首屏。
  Widget _chipsForOptions(List<DirectoryFilterTagOption> options) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options
              .map(
                (i) => ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxW),
                  child: FilterChip(
                    label: Text(
                      i.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                    selected: _interests.contains(i.value),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _interests.add(i.value);
                        } else {
                          _interests.remove(i.value);
                        }
                      });
                    },
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final bootstrapAsync = ref.watch(appBootstrapProvider(lang));
    final tagsAsync = ref.watch(directoryFilterTagOptionsProvider(lang));

    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final sheetColor =
        Theme.of(context).bottomSheetTheme.backgroundColor ??
        PostalTokens.paperEnvelope;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.92,
        child: SafeArea(
          child: bootstrapAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (bootstrap) => tagsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (tagOptions) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          PostalSectionTitle(
                            title: l10n.directoryFilterSectionTitle,
                            subtitle: l10n.directoryFilterSectionSubtitle,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.directoryFilterSort,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          // ChoiceChip 选中：secondary 底与字同为邮筒绿时不可读，局部改为白字。
                          Theme(
                            data: Theme.of(context).copyWith(
                              chipTheme: ChipTheme.of(context).copyWith(
                                secondaryLabelStyle: ChipTheme.of(context)
                                    .secondaryLabelStyle
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                checkmarkColor: Colors.white,
                              ),
                            ),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ChoiceChip(
                                  label: Text(l10n.directoryFilterNewest),
                                  selected: _sort == 'DEFAULT',
                                  onSelected: (_) =>
                                      setState(() => _sort = 'DEFAULT'),
                                ),
                                ChoiceChip(
                                  label: Text(l10n.directoryFilterClosestAge),
                                  selected: _sort == 'SAME_AGE',
                                  onSelected: (_) =>
                                      setState(() => _sort = 'SAME_AGE'),
                                ),
                                ChoiceChip(
                                  label: Text(
                                    l10n.directoryFilterSharedInterests,
                                  ),
                                  selected: _sort == 'SHARED_INTEREST',
                                  onSelected: (_) =>
                                      setState(() => _sort = 'SHARED_INTEREST'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<String?>(
                            // ignore: deprecated_member_use
                            value: _countryCode,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: l10n.directoryFilterCountryLabel,
                            ),
                            items: [
                              DropdownMenuItem<String?>(
                                value: null,
                                child: Text(l10n.directoryFilterAllCountries),
                              ),
                              ...bootstrap.countries.map(
                                (c) => DropdownMenuItem<String?>(
                                  value: c.code,
                                  child: Text(
                                    '${c.displayName(lang)} (${c.code})',
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (v) => setState(() => _countryCode = v),
                          ),
                          const SizedBox(height: 14),
                          Text(l10n.directoryFilterMinAge('$_minAge')),
                          Slider(
                            min: 45,
                            max: 90,
                            value: _minAge.toDouble(),
                            divisions: 45,
                            label: '$_minAge',
                            onChanged: (v) =>
                                setState(() => _minAge = v.round()),
                          ),
                          const SizedBox(height: 8),
                          Text(l10n.directoryFilterMaxAge('$_maxAge')),
                          Slider(
                            min: 45,
                            max: 100,
                            value: _maxAge.toDouble(),
                            divisions: 55,
                            label: '$_maxAge',
                            onChanged: (v) =>
                                setState(() => _maxAge = v.round()),
                          ),
                          const SizedBox(height: 8),
                          _filterFieldGroup(
                            context: context,
                            title: l10n.directoryFilterGender,
                            hint: l10n.directoryFilterGenderHint,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                FilterChip(
                                  label: Text(l10n.directoryFilterGenderAll),
                                  selected: _genders.isEmpty,
                                  onSelected: (_) =>
                                      setState(() => _genders.clear()),
                                ),
                                FilterChip(
                                  label: Text(l10n.authGenderMale),
                                  selected: _genders.contains(1),
                                  onSelected: (v) => setState(() {
                                    if (v) {
                                      _genders.add(1);
                                    } else {
                                      _genders.remove(1);
                                    }
                                  }),
                                ),
                                FilterChip(
                                  label: Text(l10n.authGenderFemale),
                                  selected: _genders.contains(2),
                                  onSelected: (v) => setState(() {
                                    if (v) {
                                      _genders.add(2);
                                    } else {
                                      _genders.remove(2);
                                    }
                                  }),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Divider(
                            height: 1,
                            color: PostalTokens.perforationLine.withValues(
                              alpha: 0.75,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _filterFieldGroup(
                            context: context,
                            title: l10n.directoryFilterInterests,
                            hint: l10n.directoryFilterInterestsHint,
                            child: tagOptions.isEmpty
                                ? Text(
                                    l10n.directoryFilterInterestsEmpty,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: PostalTokens.inkSecondary,
                                        ),
                                  )
                                : _chipsForOptions(tagOptions),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Material(
                    color: sheetColor,
                    elevation: 12,
                    shadowColor: PostalTokens.inkNavy.withValues(alpha: 0.14),
                    surfaceTintColor: Colors.transparent,
                    child: SafeArea(
                      top: false,
                      minimum: EdgeInsets.zero,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: PostalTokens.perforationLine.withValues(
                                alpha: 0.95,
                              ),
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              PostalButton(
                                label: l10n.directoryFilterApply,
                                onPressed: () {
                                  final min = _minAge <= _maxAge
                                      ? _minAge
                                      : _maxAge;
                                  final max = _maxAge >= _minAge
                                      ? _maxAge
                                      : _minAge;
                                  ref
                                      .read(directoryFilterProvider.notifier)
                                      .state = DirectoryFilter(
                                    countryCode: _countryCode,
                                    minAge: min,
                                    maxAge: max,
                                    interests: _interests,
                                    genders: _genders,
                                    sort: _sort,
                                  );
                                  ref.invalidate(directoryUsersProvider);
                                  Navigator.of(context).pop();
                                },
                              ),
                              const SizedBox(height: 8),
                              PostalButton(
                                label: l10n.directoryFilterClear,
                                variant: PostalButtonVariant.secondary,
                                onPressed: () {
                                  ref
                                          .read(
                                            directoryFilterProvider.notifier,
                                          )
                                          .state =
                                      const DirectoryFilter();
                                  ref.invalidate(directoryUsersProvider);
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
