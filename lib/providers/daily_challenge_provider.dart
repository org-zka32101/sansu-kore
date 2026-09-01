// Daily Challenge Provider - Riverpod state management for daily challenges and login bonuses
// Manages challenge state, login tracking, and reward calculations

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sansu_kore/models/daily_challenge_model.dart';
import 'package:sansu_kore/models/quest_model.dart';
import 'package:sansu_kore/data/stage_data.dart';

/// Daily Challenge state management
class DailyChallengeNotifier extends StateNotifier<DailyChallengeState> {
  DailyChallengeNotifier() : super(DailyChallengeState());

  /// Initialize or load today's challenge
  void loadDailyChallenge() {
    state = state.copyWith(isLoading: true);

    try {
      // Get today's date (without time)
      final today = DailyChallenge.getTodayDateOnly();
      final expiresAt = today.add(const Duration(days: 1));

      // Load 5 random questions from all stages
      final allStages = getAllStages();
      final allQuestions = <QuizQuestion>[];

      for (final stage in allStages) {
        allQuestions.addAll(stage.questions);
      }

      // Shuffle and take first 5
      allQuestions.shuffle();
      final selectedQuestions = allQuestions.take(5).toList();

      final challenge = DailyChallenge(
        dateIssued: today,
        questions: selectedQuestions,
        expiresAt: expiresAt,
      );

      state = state.copyWith(
        currentChallenge: challenge,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Record completion of today's challenge
  void completeDailyChallenge({
    required String userId,
    required int correctAnswers,
    required int totalQuestions,
  }) {
    if (state.currentChallenge == null) return;

    final challenge = state.currentChallenge!;
    final isPerfect = correctAnswers == totalQuestions;

    // Calculate coins earned
    final baseReward = challenge.baseCoinsReward;
    final streakBonus = state.loginBonus?.getStreakReward() ?? 0;
    final coinsEarned = DailyChallengeResult.calculateCoins(
      correctAnswers,
      totalQuestions,
      baseReward,
    );

    // Determine badges
    final badges = <String>[];
    if (isPerfect) {
      badges.add('完璧な挑戦');
    }
    if ((correctAnswers / totalQuestions) >= 0.8) {
      badges.add('デイリーマスター');
    }
    if (state.loginBonus != null && state.loginBonus!.currentStreak >= 7) {
      badges.add('7日連続');
    }

    final result = DailyChallengeResult(
      challengeId: challenge.id,
      userId: userId,
      completedAt: DateTime.now(),
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
      coinsEarned: coinsEarned,
      badgesUnlocked: badges,
      isPerfect: isPerfect,
    );

    state = state.copyWith(todayResult: result);
  }

  /// Reset challenge for next day (called at midnight)
  void resetForNewDay() {
    state = state.copyWith(
      currentChallenge: null,
      todayResult: null,
    );
    loadDailyChallenge();
  }
}

/// Login Bonus state management
class LoginBonusNotifier extends StateNotifier<LoginBonus?> {
  LoginBonusNotifier() : super(null);

  /// Initialize login bonus for user
  void initialize(String userId) {
    final existing = state;
    if (existing != null) {
      // User already has a login bonus record
      recordLogin(userId);
      return;
    }

    // Create new login bonus record
    state = LoginBonus.create(userId);
  }

  /// Record today's login and update streak
  void recordLogin(String userId) {
    if (state == null) {
      state = LoginBonus.create(userId);
    } else {
      state = state!.recordLogin();
    }
  }

  /// Manually set login bonus (for testing or data restore)
  void setLoginBonus(LoginBonus bonus) {
    state = bonus;
  }

  /// Reset streak (for testing)
  void resetStreak(String userId) {
    state = LoginBonus.create(userId);
  }
}

/// Providers

/// Daily challenge state provider
final dailyChallengeProvider =
    StateNotifierProvider<DailyChallengeNotifier, DailyChallengeState>((ref) {
  final notifier = DailyChallengeNotifier();
  // Auto-load challenge on creation
  notifier.loadDailyChallenge();
  return notifier;
});

/// Login bonus state provider
final loginBonusProvider = StateNotifierProvider<LoginBonusNotifier, LoginBonus?>((ref) {
  return LoginBonusNotifier();
});

/// Get today's challenge (if available)
final todaysChallengeProvider = Provider<DailyChallenge?>((ref) {
  final state = ref.watch(dailyChallengeProvider);
  if (state.currentChallenge?.isToday ?? false) {
    return state.currentChallenge;
  }
  return null;
});

/// Check if challenge is available to play today
final isChallengeAvailableProvider = Provider<bool>((ref) {
  final challengeState = ref.watch(dailyChallengeProvider);
  return challengeState.isChallengeAvailable;
});

/// Check if challenge is already completed today
final isChallengeCompletedProvider = Provider<bool>((ref) {
  final challengeState = ref.watch(dailyChallengeProvider);
  return challengeState.isChallengeCompleted;
});

/// Get current login streak
final currentLoginStreakProvider = Provider<int>((ref) {
  final bonus = ref.watch(loginBonusProvider);
  return bonus?.currentStreak ?? 0;
});

/// Get login streak reward for today
final todayLoginRewardProvider = Provider<int>((ref) {
  final bonus = ref.watch(loginBonusProvider);
  if (bonus == null) return 0;
  return bonus.getStreakReward();
});

/// Get all login bonus info
final loginBonusInfoProvider = Provider<({
  int currentStreak,
  int longestStreak,
  int todayReward,
  bool isLoggedInToday,
})?>((ref) {
  final bonus = ref.watch(loginBonusProvider);
  if (bonus == null) return null;

  return (
    currentStreak: bonus.currentStreak,
    longestStreak: bonus.longestStreak,
    todayReward: bonus.getStreakReward(),
    isLoggedInToday: bonus.isLoggedInToday,
  );
});

/// Get total daily challenge rewards (base + streak bonus)
final dailyChallengeRewardsProvider = Provider<int>((ref) {
  final challengeState = ref.watch(dailyChallengeProvider);
  final loginBonus = ref.watch(loginBonusProvider);

  if (challengeState.todayResult == null) {
    return 0; // Challenge not completed
  }

  int totalReward = challengeState.todayResult!.coinsEarned;

  // Add login streak bonus
  if (loginBonus != null) {
    totalReward += loginBonus.getStreakReward();
  }

  return totalReward;
});

/// Count of daily challenges completed this week
final weeklyCompletedChallengesProvider = Provider<int>((ref) {
  final bonus = ref.watch(loginBonusProvider);
  if (bonus == null) return 0;

  // Count logins in last 7 days
  final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
  return bonus.loginDates.where((date) => date.isAfter(oneWeekAgo)).length;
});
