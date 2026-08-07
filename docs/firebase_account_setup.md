# Firebase アカウント設定

**更新日**: 2026-06-23  
**統一メール**: `yourwishdev@gmail.com`

---

## 📋 確認リスト

### Firebase Console 設定

- [ ] [Firebase Console](https://console.firebase.google.com) にログイン
  - メール: `yourwishdev@gmail.com`
  - パスワード: [保管済み]

- [ ] プロジェクト確認
  - **プロジェクト名**: `your-wish-apps-9029a`
  - **プロジェクトID**: `your-wish-apps-9029a`

- [ ] プロジェクト設定で確認
  - **所有者**: `yourwishdev@gmail.com`
  - **メンバー**: 必要に応じて追加

---

### google-services.json 設定

**現在の状態**: ✅ `your-wish-apps-9029a` に対応

**確認方法**:
```bash
grep "package_name" android/app/google-services.json
# 期待値: "com.yourwishapps.shougakukore.sansu"
```

**必要な場合の再ダウンロード**:
1. Firebase Console → プロジェクト設定
2. 「アプリを追加」→ Android を選択
3. `com.yourwishapps.shougakukore.sansu` を入力
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

