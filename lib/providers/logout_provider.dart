import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_core/shared_core.dart';

// Firebase Auth Provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// SharedPreferences Provider
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

/// ログアウト処理を実行するProvider
/// 以下を行う:
/// 1. SharedPreferences をクリア
/// 2. Firebase Auth からログアウト
/// 3. 全Provider をリセット
final logoutProvider = FutureProvider<void>((ref) async {
  try {
    // 1. SharedPreferences をクリア
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.clear();

    // 2. Firebase Auth からログアウト
    final auth = ref.read(firebaseAuthProvider);
    await auth.signOut();

    // 3. 全Provider をリセット（重要：これでキャッシュをクリア）
    ref.invalidate(profileProvider);
    ref.invalidate(progressProvider);
    ref.invalidate(badgeProvider);
    ref.invalidate(coinProvider);
    ref.invalidate(characterProvider);
    ref.invalidate(dailyLoginProvider);
    ref.invalidate(growthProvider);
    ref.invalidate(premiumProvider);
    ref.invalidate(adaptiveProvider);
    ref.invalidate(weeklyChallengProvider);
    ref.invalidate(userReferralCodeProvider); // 紹介コード削除

  } catch (e) {
    throw Exception('ログアウト失敗: $e');
  }
});

/// ログアウト実行結果
class LogoutResult {
  final bool success;
  final String? errorMessage;

  LogoutResult({
    required this.success,
    this.errorMessage,
  });

  factory LogoutResult.success() => LogoutResult(success: true);
  factory LogoutResult.error(String message) => LogoutResult(
    success: false,
    errorMessage: message,
  );
}

/// ステートフルなログアウト機能（UI統合用）
final logoutWithUIProvider =
    StateNotifierProvider.autoDispose<LogoutNotifier, AsyncValue<void>>(
  (ref) => LogoutNotifier(ref),
);

class LogoutNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  LogoutNotifier(this._ref) : super(const AsyncValue.data(null));

  /// ログアウト処理を実行
  /// 成功時は画面遷移を行う（呼び出し元で処理）
  Future<bool> logout() async {
    state = const AsyncValue.loading();

    try {
      // 1. SharedPreferences をクリア
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // 2. Firebase Auth からログアウト
      final auth = FirebaseAuth.instance;
      await auth.signOut();

      // 3. 全Provider をリセット
      _ref.invalidate(profileProvider);
      _ref.invalidate(progressProvider);
      _ref.invalidate(badgeProvider);
      _ref.invalidate(coinProvider);
      _ref.invalidate(characterProvider);
      _ref.invalidate(dailyLoginProvider);
      _ref.invalidate(growthProvider);
      _ref.invalidate(premiumProvider);
      _ref.invalidate(adaptiveProvider);
      _ref.invalidate(weeklyChallengProvider);

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}
