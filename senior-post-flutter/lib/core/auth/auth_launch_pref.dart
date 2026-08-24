import 'package:shared_preferences/shared_preferences.dart';

const _kSkipSilentGuest = 'auth_skip_silent_guest';

/// After an explicit logout, skip auto-guest on the next cold start so the
/// user can sign in as a different account instead of resuming the bound one.
abstract final class AuthLaunchPref {
  static Future<bool> skipSilentGuest() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kSkipSilentGuest) == true;
  }

  static Future<void> setSkipSilentGuest(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSkipSilentGuest, value);
  }
}
