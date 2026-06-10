# 算数コレ！— コンセプト & 機能一覧

> 別セッションへのアイデア習得用ドキュメント。最終更新: 2026-06-10

---

## 🎯 アプリコンセプト

**ターゲット**: 小学1〜6年生（6〜12歳）  
**ジャンル**: 教育系クイズアプリ（算数）  
**シリーズ**: 小学コレ！シリーズ（国語コレ・算数コレ・カガクパズルと同列）  
**プラットフォーム**: Android（iOS予定）  
**技術スタック**: Flutter / Dart, Riverpod, Firebase, SharedPreferences

### コアバリュー
- 短時間（1ステージ5問・数分）でスキマ時間学習
- キャラクター・バッジ・コインで達成感を演出
- 学年別コンテンツで成長に合わせた難易度
- 無料5ステージ＋プレミアムで全87ステージ開放

---

## 📚 コンテンツ構成

### ステージ数・問題数（v2.1）

| 学年 | ステージ数 | 問題数 |
|------|-----------|--------|
| 小1  | 15        | 90問   |
| 小2  | 15        | 90問   |
| 小3  | 15        | 90問   |
| 小4  | 14        | 84問   |
| 小5  | 14        | 84問   |
| 小6  | 14        | 84問   |
| **合計** | **87ステージ** | **552問** |

### トピック種別（MathTopicType）

| タイプ | 絵文字 | 内容 |
|--------|--------|------|
| addition | ➕ | たし算 |
| subtraction | ➖ | ひき算 |
| multiplication | ✖️ | かけ算 |
| division | ➗ | わり算 |
| fraction | ½ | 分数 |
| decimal | 0.5 | 小数 |
| geometry | 📐 | 図形・面積 |
| word | 📝 | 文章題 |

### 学年別カバー内容

**小1**: 数の合成分解・たし算・ひき算・順序・文章題・数の大小・長さくらべ・まとめ  
**小2**: 繰り上がり計算・かけ算・1000の数・3桁計算・時刻・図形・九九9段〜0の段・まとめ  
**小3**: 大きな数・かけ算筆算・わり算・重さ・小数・分数・まとめ  
**小4**: 億・兆・小数計算・平行垂直・折れ線グラフ・面積・式の計算・まとめ  
**小5**: 整数と小数・百分率・単位量・平均・三角四角形面積・正多角形・円・まとめ  
**小6**: 拡大縮図・速さ・角柱円柱・比例反比例・資料整理・まとめ  

---

## 🎮 画面・機能一覧

### 画面構成（17画面）

| 画面 | ファイル | 説明 |
|------|---------|------|
| スプラッシュ | splash_screen.dart | 起動画面・Firebase初期化 |
| オンボーディング | onboarding_screen.dart | 初回チュートリアル |
| プロフィール選択 | profile_selection_screen.dart | キャラ選択・学年設定 |
| ホーム | home_screen.dart | メインハブ |
| ステージ選択 | stage_select_screen.dart | 学年別グリッドUI |
| クエスト（問題） | quest_screen.dart | 問題出題・回答 |
| 結果 | result_screen.dart | 正解数・コイン獲得 |
| キャラクター/バッジ | character_screen.dart | バッジ一覧・コレクション |
| ショップ | shop_screen.dart | コイン使用・アイテム購入 |
| アップグレード | upgrade_screen.dart | プレミアム課金画面 |
| 算数ガイド | math_guide_screen.dart | 学年別学習ガイド |
| ウィークリーチャレンジ | weekly_challenge_screen.dart | 週次チャレンジ |
| 成長グラフ | growth_screen.dart | 学習進捗グラフ |
| デイリーボーナス | daily_bonus_screen.dart | 毎日ログイン報酬 |
| 招待 | invite_screen.dart | 友達紹介・コード |
| 設定 | settings_screen.dart | 通知・アカウント設定 |
| プライバシーポリシー | privacy_policy_screen.dart | 法的情報 |

### ホーム画面ウィジェット構成

```
SliverAppBar（グラデーション）
  └─ アプリ名 + プロフィール名
統計行（3カード）
  ├─ 🔥 れんぞく（連続日数）
  ├─ 🪙 コイン枚数
  └─ 🎯 クリア X/87ステージ
ウィークリーチャレンジカード（紫グラデーション）
算数ガイドセクション（タップで詳細へ）
AI推奨カード（アダプティブラーニング）
クイックスタートボタン（大きな青ボタン）
最近のバッジ一覧（最大4個）
```

---

## 🏆 ゲーミフィケーション

### バッジシステム（20種）

#### content1（正解数）
| ID | 絵文字 | タイトル | 条件 |
|----|--------|---------|------|
| first_correct | ⭐ | はじめての正解 | 1問正解 |
| math_10 | 🌟 | 算数好き | 10問正解 |
| math_50 | 💫 | 計算名人 | 50問正解 |
| math_100 | 🔥 | 算数マスター | 100問正解 |
| math_200 | 🧠 | 計算の達人 | 200問正解 |
| math_300 | 👹 | 計算鬼 | 300問正解 |
| math_500 | ⚡ | 算数の神 | 500問正解 |

#### streak（連続ログイン）
| ID | 絵文字 | タイトル | 条件 |
|----|--------|---------|------|
| streak_3 | 🌱 | 3日続けた | 3日連続 |
| streak_7 | 🌿 | 1週間 | 7日連続 |
| streak_14 | 🌳 | 2週間 | 14日連続 |
| streak_30 | 🏆 | 1ヶ月 | 30日連続 |

#### score（満点クリア）
| ID | 絵文字 | タイトル | 条件 |
|----|--------|---------|------|
| perfect_1 | ✨ | 完璧 | 満点1回 |
| perfect_5 | 💎 | パーフェクター | 満点5回 |
| perfect_10 | 👑 | 完璧主義者 | 満点10回 |

#### special（ステージ達成）
| ID | 絵文字 | タイトル | 条件 |
|----|--------|---------|------|
| stage_5 | 🎯 | 第一歩 | 5ステージクリア |
| stage_10 | 📚 | 算数好き | 10ステージクリア |
| stage_20 | 🚀 | ステージマスター | 20ステージクリア |
| stage_30 | 🌈 | 虹の達人 | 30ステージクリア |
| stage_50 | 🏅 | 50クリア | 50ステージクリア |
| stage_87 | 🎊 | 算数コレクター | 全87ステージクリア |

### コインシステム
- 問題正解ごとにコイン獲得
- ショップでアイテム購入に使用
- デイリーボーナスで追加コイン

### 連続ログイン（Streak）
- 毎日起動でstreakカウント増加
- デイリーボーナスポップアップ
- 7・14・30日でバッジ解除

---

## 💎 マネタイズ

### 無料 / プレミアム区分

| 機能 | 無料 | プレミアム |
|------|------|-----------|
| 利用可能ステージ | 各学年5ステージ（計30） | 全87ステージ |
| 広告（AdMob） | あり | なし |
| ウィークリーチャレンジ | ○ | ○ |
| バッジ収集 | ○ | ○ |
| デイリーボーナス | ○ | ○ |
| 算数ガイド | ○ | ○ |

- `kFreeStageLimit = 5`（各学年5ステージまで無料）
- トライアル機能あり（trialDaysLeft表示）
- in_app_purchase（iOS/Android）

---

## 🤖 アダプティブラーニング

- トピック別正答率をトラッキング（`topicAccuracies`）
- 苦手分野を自動検出
- ホーム画面に「AIおすすめ」カードを表示（`weeklyRecommendation`）
- `AdaptiveProvider`で管理

---

## 📅 ウィークリーチャレンジ

- 毎週リセットされるチャレンジ問題セット
- `completed / total` 進捗バー表示
- 完走で特別報酬
- `WeeklyChallengeProvider`で管理

---

## 🎨 UIデザイン

### カラーパレット

| 用途 | カラー |
|------|--------|
| Primary | kPrimaryColor（青系） |
| Primary Dark | kPrimaryDark |
| Accent Green | kAccentGreen（クリア済み） |
| Accent Orange | kAccentOrange（プレミアム星） |
| Text Dark | kTextDark |
| Text Muted | kTextMuted |

### 学年カラー（ステージ選択UI）

| 学年 | カラー |
|------|--------|
| 小1 | 🔴 `#E74C3C` |
| 小2 | 🟠 `#E67E22` |
| 小3 | 🟢 `#2ECC71` |
| 小4 | 🔵 `#3498DB` |
| 小5 | 🟣 `#9B59B6` |
| 小6 | 🩵 `#1ABC9C` |

### ステージ選択グリッドUI
- 上部フィルターバー（全て / 小1〜小6）
- **全て表示**: 学年セクション区切り + 4列グリッド
- **学年絞り込み**: 3列グリッド + 進捗ヘッダー
- セルにはトピック絵文字・ステージ番号・タイトル
- クリア済み: 緑ボーダー＋右上チェック✅
- PRO限定: オレンジ星⭐＋ロック解除誘導

### ふりがな対応
- `FuriganaText` ウィジェット（`lib/widgets/furigana_text.dart`）
- `{漢字|ふりがな}` 記法でマークアップ
- 1年生ヒント・解説に適用済み
- ルビサイズ自動計算（fontSize × 0.45, 8〜12px）

---

## 🔥 Firebase構成

| サービス | 用途 | 状態 |
|---------|------|------|
| Firebase Core | 初期化 | ✅ 設定済み |
| Firebase Auth | ユーザー認証 | 設定済み・未実装 |
| Firebase Messaging | プッシュ通知 | 設定済み・未実装 |
| Firestore | データ同期 | 未実装 |

- プロジェクト: `petit-works-apps-9029a`
- App ID: `1:216377882454:android:52c82181eb491bb5d108f7`

---

## 📱 技術仕様

```yaml
# pubspec.yaml 主要依存
flutter_riverpod: ^2.6.1      # 状態管理
shared_preferences: ^2.3.0    # ローカル保存
firebase_core: ^3.13.1        # Firebase基盤
firebase_auth: ^5.5.4         # 認証
firebase_messaging: ^15.1.6   # 通知
in_app_purchase: ^3.2.0       # 課金
google_mobile_ads: ^5.2.0     # AdMob広告
google_fonts: ^6.2.1          # フォント
confetti: ^0.8.0               # 正解エフェクト
share_plus: ^10.1.4           # シェア機能
```

```
applicationId: com.petitworksapps.shougakukore.sansu
minSdk: 21 (Android 5.0+)
targetSdk: flutter.targetSdkVersion
NDK: 28.2.13676358
```

---

## 💡 改善・拡張アイデア候補

### 短期（v2.2想定）
- Firebase Auth + Firestoreでクラウドセーブ（端末間同期）
- ウィークリーチャレンジ完走バッジ追加
- 苦手分野の重点練習モード（アダプティブ強化）
- ステージクリア時のアニメーション強化

### 中期
- 保護者ダッシュボード（学習履歴レポート）
- 友達対戦モード（リアルタイム問題対戦）
- 音声読み上げ（低学年向けアクセシビリティ）
- 計算過程表示（筆算ヒント機能）

### 長期
- AI問題自動生成（Claude API活用）
- 学校・クラス連携（先生向け管理画面）
- タブレット最適化レイアウト
- Apple Watch / ウィジェット対応

---

## 🗂 ファイル構成

```
lib/
├── data/
│   ├── stage_data.dart         # 87ステージ・552問定義
│   ├── badge_data.dart         # 20バッジ定義
│   └── sansu_characters.dart   # キャラクター定義
├── models/
│   └── quest_model.dart        # Stage / QuizQuestion モデル
├── providers/
│   ├── progress_provider.dart  # 学習進捗
│   ├── premium_provider.dart   # 課金状態 (kFreeStageLimit=5)
│   ├── badge_provider.dart     # バッジ管理
│   ├── coin_provider.dart      # コイン管理
│   ├── adaptive_provider.dart  # アダプティブラーニング
│   ├── weekly_challenge_provider.dart
│   └── daily_login_provider.dart
├── screens/                    # 17画面
├── widgets/
│   └── furigana_text.dart      # {漢字|ふりがな} ウィジェット
└── theme/
    └── app_theme.dart          # カラー定数
```

---

*このドキュメントは別セッションへのコンテキスト引き継ぎ用です。*
*開発メモ詳細は `CLAUDE.md`、状態管理は `memory/project_sansu_kore.md` を参照。*
