# Phase 3: 新機能開発ロードマップ

**計画期間**: 2026年9月～11月  
**目標**: DAU +50%, セッション時間 +30%, ユーザー保持率 +40%  
**対象**: ゲーミフィケーション・エンゲージメント強化

---

## 🎮 新機能優先度ランキング

### Priority 1: 🎯 チャレンジモード（ゲームモード多様化）
**目的**: プレイ方法の多様化で飽きさせない  
**実装予定**: Week 1-2

#### 機能詳細
```
複数のゲームモード:
1. ノーマルモード（既存） - 3択から正解を選ぶ
2. タイムアタック - 制限時間内に解く
3. サバイバルモード - ミス3回でGAME OVER
4. フラッシュモード - 高速出題（反応速度テスト）
5. マラソンモード - 100問連続チャレンジ
```

**実装ファイル**:
- `lib/models/game_mode_model.dart` (新規)
- `lib/providers/game_mode_provider.dart` (新規)
- `lib/screens/challenge_select_screen.dart` (新規)
- `lib/screens/quiz_screen.dart` (修正 - モード対応)

**スコア計算**:
```dart
// タイムアタック
score = 100 + (50 - secondsSpent) * 5  // 高速ほど高スコア

// サバイバル
score = 100 * questionsCorrect  // 正解数で加算

// マラソン
score = 100 + bonusForConsecutive * streak  // 連続正解ボーナス
```

---

### Priority 2: 📅 デイリーチャレンジ & ログインボーナス
**目的**: 毎日のプレイ習慣形成  
**実装予定**: Week 2-3

#### 機能詳細
```
毎日のチャレンジ:
1. デイリークエスト
   - 毎日異なる問題セット (5問固定)
   - 完了で 50 coins 獲得
   - スタンプカード: 7日連続で追加ボーナス

2. ログインボーナス
   - 1日目: 10 coins
   - 3日目: 30 coins + ふりがなチケット
   - 7日目: 100 coins + プレミアム1日パス
   - 30日目: 300 coins + 限定キャラアンロック

3. ウィークリーチャレンジ
   - 特定の学年・トピックを集中学習
   - 完了で コイン + バッジ獲得
```

**実装ファイル**:
- `lib/models/daily_challenge_model.dart` (新規)
- `lib/providers/daily_challenge_provider.dart` (新規)
- `lib/screens/daily_challenge_screen.dart` (新規)
- `lib/widgets/login_bonus_widget.dart` (新規)

**永続化**:
```dart
// FirestoreおよびSharedPreferences
users/{userId}/daily_progress/ {
  lastLoginDate: Date,
  loginStreak: int,
  dailyQuestCompleted: bool,
  weeklyQuests: {
    quest1: completed,
    quest2: completed,
    ...
  },
  loginBonusDay: int,  // 1-30
}
```

---

### Priority 3: 🎵 サウンド & ビジュアルエフェクト
**目的**: ゲーム体験の満足度向上  
**実装予定**: Week 3-4

#### 機能詳細
```
サウンド:
1. 効果音
   - 正解音: cheerful chime (220ms)
   - 不正解音: buzzer (500ms)
   - 問題出題音: gentle ping
   - 結果表示音: fanfare (2秒)
   - UI クリック音: subtle beep

2. BGM
   - ホーム画面: calm, encouraging (loop)
   - クイズ画面: focus, slightly tense (loop)
   - 結果画面: celebration (on success)
   - ランキング画面: energetic (loop)

3. 音量設定
   - マスター音量
   - BGM/SE 個別制御
   - サイレントモード対応

ビジュアルエフェクト:
1. パーティクル
   - 正解時: confetti explosion
   - レベルアップ: sparkles
   - バッジ獲得: glow effect

2. アニメーション
   - スコア表示: number pop-up
   - ランク上昇: smooth slide
   - キャラクター喜び表現
```

**依存関係**:
- `audioplayers: ^5.2.0` (音声再生)
- `confetti: ^0.8.0` (既存 - パーティクル)

**実装ファイル**:
- `lib/services/audio_service.dart` (新規)
- `lib/providers/audio_settings_provider.dart` (新規)
- `lib/assets/sounds/` (新規 - 音声ファイル)

---

### Priority 4: ⭐ バッジ・実績システム (拡張)
**目的**: ユーザーの達成感を可視化  
**実装予定**: Week 4-5

#### 既存バッジの拡張
```
新規バッジカテゴリ:

1. スピードバッジ ⚡
   - Lightning Finger: 1秒以内に5問連続正解
   - Speed Demon: 全問平均1.5秒以下
   - Instant Master: 1問0.5秒以内

2. 精度バッジ 🎯
   - Perfect Score: ステージ満点
   - Accuracy King: ステージ正答率100%を3回
   - Flawless Run: 50問連続正解

3. チャレンジバッジ 🏆
   - Marathon Champion: 100問マラソン完了
   - Survival Expert: サバイバルモード制覇
   - Time Master: タイムアタック全クリア

4. 学習バッジ 📚
   - Grade Master: 1つのグレード全ステージクリア
   - Subject Expert: 1つのトピック全ステージクリア
   - Renaissance Man: 6つ全グレードマスター

5. 社会的バッジ 👥
   - Rising Star: ランキング初トップ100入賞
   - Leaderboard King: ランキング1位達成
   - Share King: クエスト結果を10回シェア

6. ロングランバッジ 🔥
   - Week Warrior: 7日連続プレイ
   - Month Master: 30日連続プレイ
   - Year Champion: 365日連続プレイ
```

**実装ファイル**:
- `lib/models/badge_model.dart` (修正 - 新バッジ追加)
- `lib/providers/badge_provider.dart` (修正 - 新判定ロジック)
- `lib/screens/badge_showcase_screen.dart` (新規)

**バッジ表示**:
```dart
// ユーザープロフィール
class BadgeShowcase {
  List<Badge> unlockedBadges;  // 獲得済み
  List<Badge> lockedBadges;    // 未獲得（進捗表示）
  int totalBadges;             // 全バッジ数
  int completionPercentage;    // 達成率
}
```

---

### Priority 5: 🌍 難易度レベル＆カスタマイズ
**目的**: 個々のレベルに対応した学習  
**実装予定**: Week 5-6

#### 機能詳細
```
難易度セレクター:
1. イージー (星1)
   - 基本概念のみ
   - 計算補助あり
   - 制限時間なし

2. ノーマル (星2) - デフォルト
   - 標準難易度
   - ヒント活用可能
   - 制限時間あり

3. ハード (星3)
   - 応用問題
   - ヒントなし
   - 短時間制限

4. エキスパート (星4+)
   - 複雑な複合問題
   - 高速反応必須
   - ボーナススコア大

クイズカスタマイズ:
1. 対象学年選択
   - 特定学年のみ
   - 複数学年混合
   - ランダム

2. トピック選択
   - 加算・減算のみ
   - 乗除混合
   - 全トピック

3. 問題数設定
   - 5問クイック
   - 10問標準
   - 20問チャレンジ
   - カスタム (1-50)

4. ヒント設定
   - 常に表示
   - 有料（コイン）
   - 制限付き（N回まで）
   - 無し
```

**実装ファイル**:
- `lib/models/difficulty_model.dart` (新規)
- `lib/providers/quiz_settings_provider.dart` (新規)
- `lib/screens/quiz_customizer_screen.dart` (新規)

---

### Priority 6: 🎬 チュートリアル・オンボーディング改善
**目的**: 新規ユーザーの学習曲線短縮  
**実装予定**: Week 6-7

#### 機能詳細
```
インタラクティブチュートリアル:
1. ウェルカムスクリーン
   - アプリの目的説明
   - キャラクター紹介（Lottie アニメ）
   - 学習パス説明

2. ゲーム機能チュートリアル
   - ステージ選択方法 (デモ)
   - クイズ画面操作 (インタラクティブ)
   - 結果画面説明

3. ゲーミフィケーション説明
   - ランキングの仕組み
   - バッジ・コイン
   - キャラクター育成

4. 親・教育者向けガイド
   - 子どもの進捗確認方法
   - 学習時間目安
   - プライバシー設定

5. スキップ機能
   - 各セクションで スキップ可能
   - チュートリアルサマリー画面
   - 後で見直し可能
```

**実装ファイル**:
- `lib/screens/onboarding_screen.dart` (新規)
- `lib/screens/tutorial_quiz_screen.dart` (新規)
- `lib/models/tutorial_progress_model.dart` (新規)
- `lib/providers/tutorial_provider.dart` (新規)

---

### Priority 7: 👥 友達機能・コラボレーション
**目的**: ソーシャルエンゲージメント向上  
**実装予定**: Week 7-8

#### 機能詳細
```
マルチプレイヤーモード:
1. リアルタイム対戦（将来）
   - 同じ問題を同時に解く
   - スコア競争

2. チャレンジ（非同期）
   - 友達にチャレンジ送信
   - スコア比較
   - リプレイ機能

3. グループ学習
   - クラス単位のグループ作成
   - グループランキング
   - クラス内コンテスト

シェア機能:
1. クイズ結果シェア
   - Twitter/LINE/Mail
   - スコアハイライト
   - "挑戦してみて" CTA

2. バッジシェア
   - 獲得バッジ表示
   - 友達への自慢機能
   - リンク共有でバッジボーナス

親・教育者向け:
1. クラス管理画面
   - 生徒の進捗監視
   - 学習分析ダッシュボード
   - 個別フィードバック
```

**実装ファイル**:
- `lib/models/friend_model.dart` (新規)
- `lib/providers/friend_provider.dart` (新規)
- `lib/screens/friend_screen.dart` (新規)
- `lib/screens/challenge_result_share_screen.dart` (新規)

---

## 📊 実装スケジュール

```
Week 1:   チャレンジモード実装開始
Week 2:   デイリーチャレンジ実装
Week 3-4: サウンド・VFX実装
Week 5:   バッジシステム拡張＋難易度カスタマイズ
Week 6-7: チュートリアル改善＋友達機能初期実装
Week 8:   統合テスト＋バグ修正
Week 9:   ベータテスト＆最適化
Week 10:  リリース準備
```

---

## 🔄 実装順序の根拠

### Step 1: チャレンジモード ✅ Priority 1
**理由**: 
- 既存機能を活用した最小限の新機能
- 高い DAU 改善見込み (+20-30%)
- テスト・検証容易

### Step 2: デイリーチャレンジ ✅ Priority 2
**理由**:
- チャレンジモードの後で実装
- ログイン習慣形成で保持率向上 (+30-40%)
- プッシュ通知連携で効果倍増

### Step 3: サウンド・VFX ✅ Priority 3
**理由**:
- ステップ1・2の体験を大幅改善
- 低リスク・高満足度
- 依存関係少ない（既存 confetti 活用）

### Step 4-5: バッジ＆難易度 ✅ Priority 4-5
**理由**:
- 個人カスタマイズでロングテール層対応
- Premium conversion 向上
- ユーザー多様性に対応

### Step 6-7: チュートリアル＆社会機能 ✅ Priority 6-7
**理由**:
- 新規ユーザー獲得効率向上
- リテンション強化
- ウイルス係数 (k) 向上

---

## 📈 期待効果

| 指標 | 現在 | 予想 (Phase 3後) |
|------|------|-----------------|
| DAU | - | +50% |
| セッション長 | ~8分 | ~12分 (+50%) |
| リテンション（7日） | ~35% | ~60% (+70%) |
| コンバージョンレート | ~5% | ~8% (+60%) |
| App Store Rating | 4.2 | 4.7 (+12%) |

---

## 🎯 KPI & 成功基準

### Phase 3 完了基準
- ✅ 全7機能実装済み
- ✅ 自動テスト: 80%+ カバレッジ
- ✅ 手動テスト: すべてPASS
- ✅ ベータテスター: 4.5+ 評価

### リリース基準
- ✅ クラッシュレート: < 0.1%
- ✅ App Store/Play Store 審査合格
- ✅ パフォーマンス: 60 FPS 維持
- ✅ ドキュメント: 完全

---

## 📝 関連ドキュメント

- `CLAUDE.md` - 全体プロジェクト構想
- `PHASE3_TEST_PLAN.md` - テスト計画
- `RELEASE_CHECKLIST_v3.2.0.md` - リリース準備

---

**次のステップ**: Priority 1 チャレンジモード実装開始  
**最終更新**: 2026年9月1日
