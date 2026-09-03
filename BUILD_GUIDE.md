# APK & AAB ビルドガイド

**バージョン**: 3.2.0+18  
**作成日**: 2026-09-01

## 📱 ビルド手順

### 前提条件

```bash
Flutter 3.11.5以上
Android SDK (API Level 21+)
Java 17
Gradle 7.0+
```

### 1. 環境準備

```bash
# Flutterのセットアップを確認
flutter doctor

# 依存パッケージのインストール
flutter pub get

# ビルドランナーを実行（Firebase, 自動生成コード等）
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. リリースビルド（APK）

```bash
# APKをビルド（全アーキテクチャ対応）
flutter build apk --release

# 出力ファイル:
# build/app/outputs/apk/release/app-release.apk
```

**APKの特徴:**
- サイズ: 約56-57MB
- 対応: Android 5.1+ (API 22+)
- アーキテクチャ: armv7, arm64, x86

### 3. リリースビルド（AAB - App Bundle）

```bash
# App Bundle をビルド（Google Play推奨）
flutter build appbundle --release

# 出力ファイル:
# build/app/outputs/bundle/release/app-release.aab
```

**App Bundle の利点:**
- ファイルサイズ最適化
- 動的フィーチャー配信対応
- Google Play での自動最適化

### 4. デバッグビルド（テスト用）

```bash
# デバッグAPK（開発用）
flutter build apk --debug

# 出力: build/app/outputs/apk/debug/app-debug.apk
```

## 🔐 リリース署名

### 署名キーの生成（初回のみ）

```bash
keytool -genkey -v -keystore ~/sansu_kore.keystore \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias sansu_kore_key

# 入力情報:
# Key password: [設定]
# Keystore password: [設定]
# 他: 組織情報など
```

### 署名の設定

`android/key.properties` を作成:
```properties
storePassword=[keystore_password]
keyPassword=[key_password]
keyAlias=sansu_kore_key
storeFile=/path/to/sansu_kore.keystore
```

`android/app/build.gradle` で参照:
```gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile file(keystoreProperties['storeFile'])
        storePassword keystoreProperties['storePassword']
    }
}

buildTypes {
    release {
        signingConfig signingConfigs.release
    }
}
```

## 📊 ビルド出力確認

### APKの検証

```bash
# APKの内容確認
unzip -l build/app/outputs/apk/release/app-release.apk | head -20

# ファイルサイズ確認
ls -lh build/app/outputs/apk/release/app-release.apk
ls -lh build/app/outputs/bundle/release/app-release.aab
```

### インストール・テスト

```bash
# デバイスにインストール
flutter install -v

# または APK から直接
adb install -r build/app/outputs/apk/release/app-release.apk

# アプリの起動確認
adb shell am start -n com.example.sansu_kore/.MainActivity
```

## ☁️ Google Play ストアへの提出

### 1. Google Play Console 登録

1. [Google Play Console](https://play.google.com/console) にアクセス
2. アプリを作成
3. App Bundle をアップロード

### 2. 提出前チェックリスト

- [ ] プライバシーポリシー記載
- [ ] スクリーンショット (6枚)
- [ ] アプリアイコン (512×512px)
- [ ] 説明文とタイトル
- [ ] リリースノート記入
- [ ] カテゴリ選択
- [ ] レーティング設定

### 3. リリースプロセス

```
ビルド & テスト
     ↓
App Bundle アップロード
     ↓
ストア登録情報入力
     ↓
審査申請
     ↓
Google による審査 (1-3日)
     ↓
リリース
```

## 🐛 トラブルシューティング

### ビルド失敗時

```bash
# キャッシュをクリア
flutter clean
flutter pub get

# 再度実行
flutter build apk --release

# 詳細ログを見る
flutter build apk --release -v
```

### 署名エラー

```
Error: Keystore file not found
→ key.properties で storeFile パスを確認
→ ファイルの権限確認: chmod 600 ~/sansu_kore.keystore
```

### メモリ不足

```bash
# Gradle のメモリ設定を増加
export _JAVA_OPTIONS="-Xmx4g"
flutter build apk --release
```

## 📈 リリース後の監視

### Google Play Console から確認

- アクティブなユーザー数
- クラッシュレート
- ANR（応答なし）発生率
- ユーザーレーティング

### ローカルで確認

```bash
# ログの確認
adb logcat | grep sansu_kore

# パフォーマンスプロファイリング
flutter run --profile
```

## 📋 よくある質問

**Q: APK と AAB どちらを使う？**  
A: Google Play に提出する場合は **AAB** を使用。Android デバイスへの直接インストールは **APK**。

**Q: ビルドサイズが大きすぎる**  
A: 以下を確認:
- 不要なアセット削除
- 画像を圧縮
- 未使用パッケージを削除
- ProGuard 有効化（`android/app/build.gradle`）

**Q: デバッグビルドは動くが、リリースビルドでクラッシュする**  
A: 以下の確認:
- 署名の問題
- ProGuard による難読化
- Null Safety の問題
- SharedPreferences の初期化

---

**Generated:** 2026-09-01  
**Status:** Production Ready ✅

最後のビルドコマンド:
```bash
flutter build apk --release
flutter build appbundle --release
```
