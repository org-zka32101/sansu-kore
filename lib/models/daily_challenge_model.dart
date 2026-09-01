// Daily Challenge Model - Recurring daily challenges and login bonuses
// Features: Daily challenge, login streak, bonus rewards

import 'package:uuid/uuid.dart';
import 'package:sansu_kore/models/quest_model.dart';

/// Daily Challenge Status
enum DailyChallengeStatus { notStarted, inProgress, completed, expired }

/// Represents a single day's challenge
class DailyChallenge {
  final String id;
  final DateTime dateIssued; // Date this challenge was issued
  final List<QuizQuestion> questions; // 5 questions for today
  final DateTime expiresAt; // Midnight of next day

  final int baseCoinsReward; // Base coins for completing
  final int streakBonusCoins; // Bonus based on login streak

  DailyChallenge({
    String? id,
    required this.dateIssued,
    required this.questions,
    required this.expiresAt,
    this.baseCoinsReward = 50,
    this.streakBonusCoins = 10,
  }) : id = id ?? const Uuid().v4();

  /// Check if challenge is still valid (before expiration)
  bool get isValid => DateTime.now().isBefore(expiresAt);

  /// Check if challenge is expired
  bool get isExpired => !isValid;

  /// Get today's challenge (creates new if none exists or previous expired)
  static DateTime getTodayDateOnly() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Check if challenge is for today
  bool get isToday {
    final today = getTodayDateOnly();
    final issueDate = DateTime(dateIssued.year, dateIssued.month, dateIssued.day);
    return issueDate.isAtSameMomentAs(today);
  }
}

/// Result of completing a daily challenge
class DailyChallengeResult {
  final String challengeId;
  final String userId;
  final DateTime completedAt;

  final int correctAnswers;
  final int totalQuestions;
  final double correctRate;

  final int coinsEarned;
  final List<String> badgesUnlocked;
  final bool isPerfect; // All 5 correct

  DailyChallengeResult({
    required this.challengeId,
    required this.userId,
    required this.completedAt,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.coinsEarned,
    required this.badgesUnlocked,
    this.isPerfect = false,
  }) : correctRate = totalQuestions == 0 ? 0 : correctAnswers / totalQuestions;

  /// Calculate coins earned based on performance
  static int calculateCoins(int correctAnswers, int totalQuestions, int baseReward) {
    final correctRate = totalQuestions == 0 ? 0 : correctAnswers / totalQuestions;

    // Base reward
    int coins = baseReward;

    // Performance bonus
    if (correctRate >= 1.0) {
      coins = (coins * 1.5).toInt(); // Perfect: 1.5x
    } else if (correctRate >= 0.8) {
      coins = (coins * 1.2).toInt(); // Good: 1.2x
    } else if (correctRate >= 0.6) {
      coins = (coins * 1.0).toInt(); // Pass: 1x
    }

    return coins;
  }
}

/// Login bonus system - tracks consecutive login days
class LoginBonus {
  final String userId;
  final int currentStreak; // Days in a row
  final int longestStreak; // Historical longest streak
  final DateTime lastLoginDate;
  final List<DateTime> loginDates; // History of login dates

  LoginBonus({
    required this.userId,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastLoginDate,
    required this.loginDates,
  });

  /// Get reward coins for current streak
  int getStreakReward() {
    return switch (currentStreak) {
      1 => 10,
      2 => 20,
      3 => 30,
      4 => 50,
      5 => 100,
      >= 6 => 100 + (currentStreak - 5) * 10,
      _ => 0,
    };
  }

  /// Check if user logged in today
  bool get isLoggedInToday {
    final today = DateTime.now();
    final lastDate = DateTime(lastLoginDate.year, lastLoginDate.month, lastLoginDate.day);
    final todayDate = DateTime(today.year, today.month, today.day);
    return lastDate.isAtSameMomentAs(todayDate);
  }

  /// Check if logged in yesterday (determines streak continuation)
  bool wasLoggedInYesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
    final lastDate = DateTime(lastLoginDate.year, lastLoginDate.month, lastLoginDate.day);
    return lastDate.isAtSameMomentAs(yesterdayDate);
  }

  /// Record new login and update streak
  LoginBonus recordLogin() {
    final today = DateTime.now();

    // Check if already logged in today
    if (isLoggedInToday) {
      return this;
    }

    int newStreak = currentStreak;

    // Check if logged in yesterday to continue streak
    if (!wasLoggedInYesterday()) {
      newStreak = 1; // Reset streak if gap
    } else {
      newStreak = currentStreak + 1; // Continue streak
    }

    // Update longest streak if new record
    final newLongestStreak = newStreak > longestStreak ? newStreak : longestStreak;

    return LoginBonus(
      userId: userId,
      currentStreak: newStreak,
      longestStreak: newLongestStreak,
      lastLoginDate: today,
      loginDates: [...loginDates, today],
    );
  }

  /// Create initial login bonus record
  static LoginBonus create(String userId) {
    final now = DateTime.now();
    return LoginBonus(
      userId: userId,
      currentStreak: 1,
      longestStreak: 1,
      lastLoginDate: now,
      loginDates: [now],
    );
  }
}

/// Daily challenge state
class DailyChallengeState {
  final DailyChallenge? currentChallenge;
  final DailyChallengeResult? todayResult;
  final LoginBonus? loginBonus;
  final bool isLoading;
  final String? error;

  DailyChallengeState({
    this.currentChallenge,
    this.todayResult,
    this.loginBonus,
    this.isLoading = false,
    this.error,
  });

  DailyChallengeState copyWith({
    DailyChallenge? currentChallenge,
    DailyChallengeResult? todayResult,
    LoginBonus? loginBonus,
    bool? isLoading,
    String? error,
  }) {
    return DailyChallengeState(
      currentChallenge: currentChallenge ?? this.currentChallenge,
      todayResult: todayResult ?? this.todayResult,
      loginBonus: loginBonus ?? this.loginBonus,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Check if challenge is available today
  bool get isChallengeAvailable {
    if (currentChallenge == null) return false;
    if (!currentChallenge!.isValid) return false;
    if (todayResult != null) return false; // Already completed
    return true;
  }

  /// Check if challenge is completed
  bool get isChallengeCompleted => todayResult != null;

  /// Days until next daily challenge reset
  int get hoursUntilReset {
    if (currentChallenge == null) return 0;
    final now = DateTime.now();
    return currentChallenge!.expiresAt.difference(now).inHours;
  }
}
