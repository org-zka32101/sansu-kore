# Firebase アカウント設定

**更新日**: 2026-06-23  
**統一メール**: `petitworksdev@gmail.com`

---

## 📋 確認リスト

### Firebase Console 設定

- [ ] [Firebase Console](https://console.firebase.google.com) にログイン
  - メール: `petitworksdev@gmail.com`
  - パスワード: [保管済み]

- [ ] プロジェクト確認
  - **プロジェクト名**: `petit-works-apps-9029a`
  - **プロジェクトID**: `petit-works-apps-9029a`

- [ ] プロジェクト設定で確認
  - **所有者**: `petitworksdev@gmail.com`
  - **メンバー**: 必要に応じて追加

---

### google-services.json 設定

**現在の状態**: ✅ `petit-works-apps-9029a` に対応

**確認方法**:
```bash
grep "package_name" android/app/google-services.json
# 期待値: "com.yourwish.shougakukore.sansu"
```

**必要な場合の再ダウンロード**:
1. Firebase Console → プロジェクト設定
2. 「アプリを追加」→ Android を選択
3. `com.yourwish.shougakukore.sansu` を入力
4. google-services.json をダウンロード
5. `android/app/google-services.json` に上書き

---

## 🔐 セキュリティチェック

- [ ] Firebase Authentication
  - プロバイダ: Google, Email/Password
  - 許可ドメイン: localhost, Firebase Hosting ドメイン

- [ ] Firestore セキュリティルール
  - 本番ルール: ユーザー認証ベース
  - 開発ルール: テスト用に緩和（本番前に修正）

- [ ] Cloud Storage ルール
  - ユーザーは自分のファイルのみアクセス可能

---

## 📊 プロジェクト構成

```
Firestore Collections:
├─ users/
│  ├─ {uid}/
│  │  ├─ profile (名前、学年、アバター)
│  │  ├─ progress (進捗、ストリーク)
│  │  ├─ badges (バッジ獲得履歴)
│  │  ├─ coins (コイン残高)
│  │  └─ characters (キャラクターレベル)
├─ leaderboards/
├─ announcements/
└─ config/

Cloud Functions:
├─ onUserCreated (新規ユーザー初期化)
├─ recordBadgeEarned (バッジ獲得時処理)
└─ updateLeaderboard (ランキング更新)

Cloud Storage:
└─ /user-data/profile-pictures/{uid}/avatar.jpg
```

---

## ✅ デプロイ前チェック

- [ ] 本番 Firestore ルールを設定
- [ ] Cloud Functions をデプロイ
- [ ] 環境変数（Firebase config）を確認
- [ ] エミュレータでテスト（開発時）

---

**次のステップ**: Firebase 本設定と Cloud Functions デプロイ

