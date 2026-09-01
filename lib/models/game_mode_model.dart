// Game Mode Models for Challenge Modes
// Supports: Normal, Time Attack, Survival, Flash, Marathon

import 'package:flutter/foundation.dart';

enum GameMode {
  normal,      // 通常モード: 3択から選ぶ
  timeAttack,  // タイムアタック: 制限時間内に解く
  survival,    // サバイバル: ミス3回でGAME OVER
  flash,       // フラッシュ: 高速出題
  marathon,    // マラソン: 100問連続
}

enum GameModeStatus {
  active,      // プレイ中
  paused,      // 一時停止
  completed,   // 完了
  failed,      // 失敗
}

/// ゲームモード設定
class GameModeConfig {
  final GameMode mode;
  final String displayName;      // 表示名（日本語）
  final String description;      // 説明文
  final String? emoji;           // 絵文字

  // タイムアタック設定
  final int? timeLimit;          // 秒単位（null = 無制限）

  // サバイバル設定
  final int? maxMisses;          // 最大ミス数（3推奨）

  // フラッシュ設定
  final int? questionsPerRound;  // 1ラウンドの問題数（5-10推奨）
  final int? roundDelayMs;       // 問題間の表示時間（ms）

  // マラソン設定
  final int? targetQuestionsCount; // 目標問題数（100推奨）

  const GameModeConfig({
    required this.mode,
    required this.displayName,
    required this.description,
    this.emoji,
    this.timeLimit,
    this.maxMisses,
    this.questionsPerRound,
    this.roundDelayMs,
    this.targetQuestionsCount,
  });

  /// 静的コンフィグ: 全ゲームモード
  static const List<GameModeConfig> allModes = [
    GameModeConfig(
      mode: GameMode.normal,
      displayName: 'ノーマルモード',
      description: '3択から正解を選ぼう！制限時間なし。基本的な学習モード。',
      emoji: '📖',
    ),
    GameModeConfig(
      mode: GameMode.timeAttack,
      displayName: 'タイムアタック',
      description: '制限時間内に解く！速度が高いほど高スコア。速さと正確性の勝負。',
      emoji: '⏱️',
      timeLimit: 60,  // 60秒/問題
    ),
    GameModeConfig(
      mode: GameMode.survival,
      displayName: 'サバイバル',
      description: 'ミス3回でGAME OVER！どこまで続けられるか。連続正解でスコア加算。',
      emoji: '💪',
      maxMisses: 3,
    ),
    GameModeConfig(
      mode: GameMode.flash,
      displayName: 'フラッシュモード',
      description: '高速出題！反応速度がカギ。短い時間で判断力を鍛える。',
      emoji: '⚡',
      questionsPerRound: 10,
      roundDelayMs: 1000,
    ),
    GameModeConfig(
      mode: GameMode.marathon,
      displayName: 'マラソン',
      description: '100問連続チャレンジ！持久力と集中力の最終テスト。',
      emoji: '🏃',
      targetQuestionsCount: 100,
    ),
  ];

  /// モード設定を取得
  static GameModeConfig? getConfig(GameMode mode) {
    try {
      return allModes.firstWhere((m) => m.mode == mode);
    } catch (e) {
      return null;
    }
  }
}

/// ゲーム内の問題（質問）
class GameQuestion {
  final String id;
  final String question;
  final List<String> choices;
  final int correctIndex;
  final String? explanation;

  GameQuestion({
    required this.id,
    required this.question,
    required this.choices,
    required this.correctIndex,
    this.explanation,
  });
}

/// ユーザーの回答
class UserAnswer {
  final String questionId;
  final int? selectedIndex;    // null = 未回答
  final bool isCorrect;
  final int responseTime;       // ミリ秒
  final DateTime answeredAt;

  UserAnswer({
    required this.questionId,
    required this.selectedIndex,
    required this.isCorrect,
    required this.responseTime,
    required this.answeredAt,
  });
}

/// ゲームセッション状態
class GameSession {
  final String sessionId;
  final GameMode gameMode;
  final int gradeLevel;
  final String? topicType;              // null = ランダム
  final DateTime startedAt;

  // セッション進行状況
  int correctAnswers = 0;
  int totalQuestions = 0;
  int totalMisses = 0;
  int currentStreak = 0;                // 連続正解数
  int maxStreak = 0;                    // 最大連続正解
  int elapsedSeconds = 0;               // 経過時間（秒）

  // 回答履歴
  List<UserAnswer> answers = [];

  // ゲーム状態
  GameModeStatus status = GameModeStatus.active;
  DateTime? completedAt;

  GameSession({
    required this.sessionId,
    required this.gameMode,
    required this.gradeLevel,
    this.topicType,
    required this.startedAt,
  });

  /// 正答率を計算
  double get correctRate {
    if (totalQuestions == 0) return 0.0;
    return correctAnswers / totalQuestions;
  }

  /// 平均回答時間（秒）を計算
  double get averageResponseTime {
    if (answers.isEmpty) return 0.0;
    final totalMs = answers.fold<int>(0, (sum, a) => sum + a.responseTime);
    return (totalMs / answers.length) / 1000.0;
  }

  /// ゲーム終了
  void complete() {
    status = GameModeStatus.completed;
    completedAt = DateTime.now();
  }

  /// ゲーム失敗（サバイバル時）
  void fail() {
    status = GameModeStatus.failed;
    completedAt = DateTime.now();
  }
}

/// ゲーム結果・スコア計算
class GameResult {
  final String sessionId;
  final GameMode gameMode;
  final DateTime completedAt;

  // スコア情報
  final int baseScore;           // 基本スコア（正解数 × 100）
  final int speedBonus;          // 速度ボーナス
  final int streakBonus;         // 連続正解ボーナス
  final int difficultyMultiplier; // 難易度倍率

  // ゲーム統計
  final int correctAnswers;
  final int totalQuestions;
  final double correctRate;
  final double averageResponseTime;
  final int maxStreak;
  final int totalMisses;
  final int elapsedSeconds;

  // 獲得報酬
  final int coinsEarned;
  final List<String> badgesUnlocked;
  final bool newRecord;          // 新記録達成

  GameResult({
    required this.sessionId,
    required this.gameMode,
    required this.completedAt,
    required this.baseScore,
    required this.speedBonus,
    required this.streakBonus,
    required this.difficultyMultiplier,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.correctRate,
    required this.averageResponseTime,
    required this.maxStreak,
    required this.totalMisses,
    required this.elapsedSeconds,
    required this.coinsEarned,
    required this.badgesUnlocked,
    required this.newRecord,
  });

  /// 総スコア計算
  int get totalScore {
    return (baseScore + speedBonus + streakBonus) * difficultyMultiplier;
  }

  /// スコア計算ロジック（static メソッド）
  static GameResult calculateResult({
    required String sessionId,
    required GameMode gameMode,
    required int correctAnswers,
    required int totalQuestions,
    required double correctRate,
    required double averageResponseTime,
    required int maxStreak,
    required int totalMisses,
    required int elapsedSeconds,
  }) {
    // 基本スコア
    int baseScore = correctAnswers * 100;

    // 速度ボーナス（平均応答時間が短いほど加点）
    int speedBonus = 0;
    if (averageResponseTime < 1.0) {
      speedBonus = 100;  // 1秒以下
    } else if (averageResponseTime < 2.0) {
      speedBonus = 50;   // 2秒以下
    }

    // 連続正解ボーナス
    int streakBonus = maxStreak > 5 ? (maxStreak - 5) * 10 : 0;

    // 難易度倍率（応答時間・正答率で決定）
    int difficultyMultiplier = 1;
    if (correctRate >= 0.95 && averageResponseTime < 1.5) {
      difficultyMultiplier = 2;  // 高難易度達成
    } else if (correctRate >= 0.85 || averageResponseTime < 2.0) {
      difficultyMultiplier = 1;  // 標準
    }

    // ゲームモード別ボーナス調整
    if (gameMode == GameMode.marathon) {
      speedBonus = (speedBonus * 1.5).toInt();  // マラソンは速度重視
      streakBonus = (streakBonus * 2).toInt();  // 連続正解が重要
    } else if (gameMode == GameMode.timeAttack) {
      speedBonus = (speedBonus * 2).toInt();    // タイムアタックは速度最重視
    }

    // コイン獲得（正答率で決定）
    int coinsEarned = 0;
    if (correctRate >= 0.9) {
      coinsEarned = 150;  // A+: 90%以上正解
    } else if (correctRate >= 0.8) {
      coinsEarned = 100;  // A: 80%以上
    } else if (correctRate >= 0.7) {
      coinsEarned = 50;   // B: 70%以上
    } else if (correctRate >= 0.6) {
      coinsEarned = 25;   // C: 60%以上
    } else {
      coinsEarned = 0;    // F: 60%未満
    }

    // バッジ判定（後で実装）
    List<String> badgesUnlocked = [];
    if (correctRate == 1.0) {
      badgesUnlocked.add('perfect_score');
    }
    if (maxStreak >= 10) {
      badgesUnlocked.add('streak_master');
    }
    if (averageResponseTime < 1.0) {
      badgesUnlocked.add('lightning_fast');
    }

    return GameResult(
      sessionId: sessionId,
      gameMode: gameMode,
      completedAt: DateTime.now(),
      baseScore: baseScore,
      speedBonus: speedBonus,
      streakBonus: streakBonus,
      difficultyMultiplier: difficultyMultiplier,
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
      correctRate: correctRate,
      averageResponseTime: averageResponseTime,
      maxStreak: maxStreak,
      totalMisses: totalMisses,
      elapsedSeconds: elapsedSeconds,
      coinsEarned: coinsEarned,
      badgesUnlocked: badgesUnlocked,
      newRecord: false,  // TODO: 実装
    );
  }
}

/// ゲームモード統計
class GameModeStats {
  final GameMode gameMode;
  final int timesPlayed;
  final int totalScore;
  final double averageScore;
  final double bestScore;
  final double averageCorrectRate;
  final DateTime? lastPlayed;

  GameModeStats({
    required this.gameMode,
    required this.timesPlayed,
    required this.totalScore,
    required this.averageScore,
    required this.bestScore,
    required this.averageCorrectRate,
    this.lastPlayed,
  });
}
