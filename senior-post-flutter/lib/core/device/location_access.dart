import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:senior_post_flutter/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/theme/postal_tokens.dart';
import '../../features/auth/auth_repository.dart';
import '../../widgets/postal/postal.dart';
import '../auth/auth_token.dart';
import 'guest_geo.dart';

/// 系统定位只在冷启动问一次；设置里用户主动再问。
enum LocationPromptReason {
  /// 冷启动：系统授权弹窗先于静默 guest。
  bootstrap,

  /// 写信 / 寄给有缘人 / 时光信（不再弹系统窗，只同步已授权坐标）。
  compose,

  /// 「我的」资料页：匹配城市仍缺坐标。
  profile,

  /// 信箱：收信/匹配仍缺坐标。
  mailbox,

  /// 设置里用户主动打开定位。
  settings,
}

const _kBootstrapAskedKey = 'location_os_permission_asked';

/// 本进程内每个触发点只弹一次，避免同一页反复 requestPermission。
final class LocationPromptMemory {
  LocationPromptMemory._();

  static final Set<LocationPromptReason> _asked = <LocationPromptReason>{};

  static bool consume(LocationPromptReason reason) {
    if (reason == LocationPromptReason.settings) {
      return true;
    }
    if (_asked.contains(reason)) {
      return false;
    }
    _asked.add(reason);
    return true;
  }

  @visibleForTesting
  static void reset() => _asked.clear();
}

final locationAccessProvider = Provider<LocationAccess>((ref) {
  return LocationAccess(ref);
});

/// 定位授权与坐标上报。拒绝不阻断业务；已登录且有坐标则 PATCH `/api/auth/profile`。
class LocationAccess {
  LocationAccess(this._ref);

  final Ref _ref;

  /// 在需要定位的动作前询问。允许/拒绝都继续；永久拒绝则引导去系统设置。
  /// OS 弹窗仅 bootstrap / settings；其它入口只同步已有坐标。
  Future<void> ensureAsked({
    required BuildContext context,
    required LocationPromptReason reason,
  }) async {
    if (skipOsLocationPlugin) {
      return;
    }
    if (reason != LocationPromptReason.bootstrap &&
        reason != LocationPromptReason.settings) {
      await syncToServerIfPossible();
      return;
    }
    if (!LocationPromptMemory.consume(reason)) {
      await syncToServerIfPossible();
      return;
    }
    try {
      var permission = await Geolocator.checkPermission();
      final granted = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
      if (granted) {
        await syncToServerIfPossible();
        return;
      }
      if (reason == LocationPromptReason.bootstrap &&
          !await _shouldAskBootstrapOsDialog()) {
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        if (reason != LocationPromptReason.bootstrap && context.mounted) {
          await _showOpenSettingsDialog(context);
        }
        return;
      }
      // Android 必须在 Activity 就绪后 requestPermission，否则系统弹窗不会出现。
      if (reason == LocationPromptReason.bootstrap) {
        await Future<void>.delayed(const Duration(milliseconds: 280));
      }
      permission = await Geolocator.requestPermission();
      if (reason == LocationPromptReason.bootstrap) {
        await _markBootstrapAsked();
      }
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        await syncToServerIfPossible();
        return;
      }
      if (permission == LocationPermission.deniedForever &&
          reason != LocationPromptReason.bootstrap &&
          context.mounted) {
        await _showOpenSettingsDialog(context);
      }
    } catch (e) {
      debugPrint('location ensureAsked failed: $e');
    }
  }

  /// 从系统设置返回后：若已授权则补报坐标。无 token 时跳过（guest 请求会带上）。
  Future<void> syncToServerIfPossible() async {
    final token = _ref.read(authTokenProvider);
    if (token == null || token.isEmpty) {
      return;
    }
    final geo = await readGuestCoordinates();
    if (geo.latitude == null || geo.longitude == null) {
      return;
    }
    try {
      await _ref.read(authRepositoryProvider).updateProfileOnServer(
            latitude: geo.latitude,
            longitude: geo.longitude,
          );
    } catch (e) {
      debugPrint('location profile patch failed: $e');
    }
  }

  Future<bool> _shouldAskBootstrapOsDialog() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kBootstrapAskedKey) != true;
  }

  Future<void> _markBootstrapAsked() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kBootstrapAskedKey, true);
  }

  Future<void> _showOpenSettingsDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: PostalTokens.paperEnvelope,
          icon: const Icon(
            Icons.location_on_outlined,
            color: PostalTokens.postboxGreen,
            size: 48,
          ),
          title: Text(l10n.locationSettingsTitle),
          content: Text(
            l10n.locationSettingsBody,
            style: Theme.of(ctx).textTheme.bodyLarge?.copyWith(height: 1.45),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Column(
              children: [
                SizedBox(
                  width: 260,
                  child: PostalButton(
                    label: l10n.locationSettingsOpen,
                    expand: false,
                    onPressed: () => Navigator.pop(ctx, true),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 260,
                  child: PostalButton(
                    label: l10n.locationSettingsLater,
                    variant: PostalButtonVariant.secondary,
                    expand: false,
                    onPressed: () => Navigator.pop(ctx, false),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
    if (go == true) {
      await Geolocator.openAppSettings();
    }
  }
}
