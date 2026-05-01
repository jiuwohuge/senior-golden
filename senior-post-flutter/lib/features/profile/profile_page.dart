import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_token.dart';
import '../../core/bootstrap/app_bootstrap.dart';
import '../../core/network/dio_provider.dart';
import '../auth/auth_repository.dart';
import '../auth/login_routes.dart';

final profileDataProvider = FutureProvider<ProfileViewData>((ref) async {
  ref.watch(authTokenProvider);
  final dio = ref.read(dioProvider);
  final bootstrap = await ref.watch(appBootstrapProvider.future);
  final meRes = await dio.get<Map<String, dynamic>>('/api/auth/me');
  final meRaw = unwrapData<Map<String, dynamic>>(meRes, (raw) {
    return raw! as Map<String, dynamic>;
  });
  return ProfileViewData(
    user: ProfileUser.fromJson(meRaw),
    minRegisterAge: bootstrap.minRegisterAge,
    countries: bootstrap.countries,
  );
});

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(profileDataProvider);
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text('Load profile failed: $error'),
          ),
        ),
        data: (data) {
          final lang = Localizations.localeOf(context).languageCode;
          final countryName = _findCountryName(data, lang);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.user.nickname ?? '-',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text('Email: ${data.user.email ?? '-'}'),
                      Text('Birth Year: ${data.user.birthYear ?? '-'}'),
                      Text('Country: $countryName'),
                      Text('Stamps: ${data.user.stampsBalance ?? 0}'),
                      Text('VIP: ${data.user.isVip == true ? 'Yes' : 'No'}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bootstrap config',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text('Minimum register age: ${data.minRegisterAge}'),
                      Text('Countries loaded: ${data.countries.length}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: () async {
                  await ref.read(authRepositoryProvider).logout();
                  if (context.mounted) context.go(LoginRoutes.login);
                },
                child: const Text('Logout'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _findCountryName(ProfileViewData data, String languageCode) {
    final code = data.user.countryCode;
    if (code == null || code.isEmpty) {
      return '-';
    }
    CountryItem? matched;
    for (final country in data.countries) {
      if (country.code == code) {
        matched = country;
        break;
      }
    }
    if (matched == null) {
      return code;
    }
    return '${matched.displayName(languageCode)} ($code)';
  }
}

class ProfileViewData {
  const ProfileViewData({
    required this.user,
    required this.minRegisterAge,
    required this.countries,
  });

  final ProfileUser user;
  final int minRegisterAge;
  final List<CountryItem> countries;
}

class ProfileUser {
  const ProfileUser({
    this.email,
    this.nickname,
    this.birthYear,
    this.countryCode,
    this.stampsBalance,
    this.isVip,
  });

  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    return ProfileUser(
      email: json['email'] as String?,
      nickname: json['nickname'] as String?,
      birthYear: (json['birthYear'] as num?)?.toInt(),
      countryCode: json['countryCode'] as String?,
      stampsBalance: (json['stampsBalance'] as num?)?.toInt(),
      isVip: json['isVip'] as bool?,
    );
  }

  final String? email;
  final String? nickname;
  final int? birthYear;
  final String? countryCode;
  final int? stampsBalance;
  final bool? isVip;
}
