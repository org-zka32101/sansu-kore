# 算数コレ！— iOSビルド設定ガイド

**現状**: Windows環境のため実機用 .ipa は生成不可（Xcode必須）。
GitHub Actions の macOS ランナーで代替検証する体制を整備済み。

---

## 今回の対応内容

### 1. 発見した不具合の修正

| 問題 | 内容 | 対応 |
|------|------|------|
| Info.plist表示名誤り | `CFBundleDisplayName` が "Kokugo Kore"（国語コレからのコピペ残骸） | 「算数コレ！」に修正済み ✅ |
| **ブランチ名不一致（最重要）** | ワークフローの起動条件が `branches: [main]` だったが、このリポジトリに `main` ブランチは存在せず実際は `master` のみ。**これまでのpushでActionsは一度も起動していなかった** | `master` に修正済み ✅ |
| GitHub Actions パスバグ | ワークフローが `cd sansu-kore` していたが、リポジトリ直下がFlutterプロジェクトのため存在しないディレクトリを参照していた | 修正済み ✅ |
| CIのFlutterバージョンが古すぎる | `flutter-version: '3.24.0'` 指定だと、bundleされるDart SDKが `pubspec.yaml` の `sdk: ^3.11.5` 制約を満たせず `pub get` が失敗する | 他プロジェクト（日本の未来マップ）で実績のある `3.44.0` に統一 ✅ |
| iOS Firebase未設定 | `firebase_options.dart` がiOS向けに未設定（`UnsupportedError`を投げる状態） | 下記「必要な追加作業」参照 |
| Podfile不在 | iOSで一度もビルドされたことがなく `ios/Podfile` が生成されていなかった | 日本の未来マップ（Firebase同梱・実績あり）のPodfileを流用して新規作成 ✅ |

### 2. GitHub Actions を3層構成に刷新（コスト最適化）

macOSランナーはLinuxの**10倍**のActions分数を消費するため、以下の3層構成に刷新（他プロジェクトでの実際のコスト超過インシデントを踏まえた対応）：

| ジョブ | 実行環境 | 起動条件 |
|--------|---------|---------|
| `test`（analyze） | ubuntu-latest | push / PR / 手動 |
| `build-android`（APK+AAB） | ubuntu-latest | push / PR / 手動 |
| `build-ios`（署名なし） | macos-latest | **PR時 or 手動のみ**（pushでは起動しない） |
| `build-ios-signed`（TestFlight配布） | macos-latest | **手動のみ**（Secrets未設定のため現時点では失敗する想定） |

### 3. Podfile を新規作成（gRPC/BoringSSL既知問題への対策込み）

Firebase系パッケージ（firebase_core/cloud_firestore等）が新しいXcodeでビルド失敗する既知の問題（`-G`フラグ・gRPC-Coreのテンプレート構文エラー）に対する`post_install`フックを実績のあるテンプレートから移植済み。

---

## ユーザー側で必要な追加作業

### A. Firebase Console で iOS アプリを登録（必須）

現在 Firebase プロジェクト `petit-works-education` には
Android アプリ（`com.petitworksapps.shougakukore.sansu`）のみ登録されており、
iOS アプリの登録がありません。

**手順**:
1. https://console.firebase.google.com/project/petit-works-education/settings/general
2. 「アプリを追加」→ iOS を選択
3. バンドルID: `jp.petitworks.SansuKore`
4. 「GoogleService-Info.plist」をダウンロード
5. `H:\マイドライブ\apps\sansu-kore\ios\Runner\GoogleService-Info.plist` に配置
6. Xcodeで開いてRunnerターゲットに追加する必要があるため、実際にはMacでの一度の作業が必要
   （またはCI側で自動配置するようGitHub Secretsに base64化して登録する方法もあり）
7. `flutterfire configure` を実行すると `lib/firebase_options.dart` にiOS設定が自動反映される

### B. Apple Developer Program 登録（実機配布・App Store申請に必須）

- 年会費 $99/年
- https://developer.apple.com/programs/enroll/
- 登録後、Bundle ID `jp.petitworks.SansuKore` をApple Developer Portalでも登録

### C. 実機ビルド・TestFlight配布にはMac実機 or クラウドMacが必要

Windows単体では以下ができません：
- コード署名（Provisioning Profile / Certificate）
- 実機インストール
- App Store Connect へのアップロード

**選択肢**:
1. **Mac実機を用意**（中古Mac miniなど、最も確実）
2. **Codemagic / Bitrise 等のクラウドMac CI**（無料枠あり、GitHub連携可能）
3. **GitHub Actions + fastlane match**（署名の自動化、上級者向け）

---

## 現時点でできること・できないこと

```
✅ できる（Windows + GitHub Actions のみ）
- Dartコードのコンパイルエラー検証（flutter build ios --no-codesign）
- Info.plist / Xcodeプロジェクト設定の静的な確認・修正
- pubspec.yaml のiOS対応パッケージ確認

❌ できない（Mac/Xcode必須）
- 実機での動作確認
- コード署名付きビルド(.ipa)生成
- TestFlight / App Store への提出
```

---

## 次のアクション（優先順）

1. Firebase Console で iOS アプリ登録 → GoogleService-Info.plist 取得
2. Apple Developer Program 登録（まだの場合）
3. Mac環境の確保（実機 or クラウドMac CI）
4. `flutterfire configure` でiOS設定を本反映
5. 署名付きビルド用の GitHub Secrets を登録（`build-ios-signed`ジョブが必要とする値）:
   - `IOS_DIST_CERT_BASE64` / `IOS_DIST_CERT_PASSWORD`（配布証明書 .p12）
   - `IOS_PROVISION_PROFILE_BASE64`（プロビジョニングプロファイル）
   - `APP_STORE_CONNECT_API_KEY_BASE64` / `APP_STORE_CONNECT_KEY_ID` / `APP_STORE_CONNECT_ISSUER_ID`
   - `ios/ExportOptions.plist` の作成
6. 実機ビルド・TestFlight配布へ（Actionsタブ →「Run workflow」で`build-ios-signed`を手動起動）

## Actions実行時の注意（コスト管理）

`build-ios` / `build-ios-signed` は **手動実行（Actionsタブ → Run workflow）を選ぶまで自動起動しません**。
Podfile調整などで何度も試行錯誤する場合は、まとめて手動実行するようにし、pushのたびに無駄なmacOS課金が発生しないよう注意してください。

