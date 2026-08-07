# Firestore セキュリティルール設定

**バージョン**: v1.0  
**プロジェクト**: your-wish-education  
**更新日**: 2026-06-23

---

## 📋 ルール概要

### セキュリティ戦略

- **認証**: Firebase Authentication (Google, Email/Password)
- **アクセス制御**: ユーザー ID ベース（UID）
- **個人データ**: ユーザー本人のみアクセス
- **公開データ**: 認証ユーザーは読み取り可能（書き込み不可）

---

## 📁 コレクション構造と権限

```
users/{uid}/
  ├─ profile          → 所有者のみ R/W
  ├─ progress         → 所有者のみ R/W
  ├─ badges/          → 所有者のみ R/W
  ├─ coins            → 所有者のみ R/W
  ├─ characters/      → 所有者のみ R/W
  ├─ dailyLogin       → 所有者のみ R/W
  └─ streak           → 所有者のみ R/W

leaderboards/{doc}   → 全員読み（CF書き込み）
announcements/{doc}  → 全員読み（CF書き込み）
config/{doc}         → 全員読み（CF書き込み）
gameEvents/{doc}     → 全員読み（CF書き込み）
```

---

## 🚀 デプロイ手順

### 方法A: Firebase Console（ブラウザ）

1. **Firebase Console にログイン**
   ```
   https://console.firebase.google.com/
   メール: yourwishdev@gmail.com
   プロジェクト: your-wish-education
   ```

2. **Firestore Database を選択**
   - 左メニュー → `Firestore Database`

3. **ルール タブをクリック**
   - 上部の「ルール」タブを開く

4. **新しいルールをコピー＆ペースト**
   - ファイル: `firebase/firestore.rules` の内容をコピー
   - Console のエディタに貼り付け

5. **発行をクリック**
   - 「発行」ボタンをクリック
   - デプロイが完了するまで待機（1〜2分）

---

### 方法B: Firebase CLI（ターミナル）

1. **Firebase CLI をインストール**
   ```bash
   npm install -g firebase-tools
   ```

2. **ログイン**
   ```bash
   firebase login
   # ブラウザで yourwishdev@gmail.com でログイン
   ```

3. **プロジェクトを初期化**
   ```bash
   cd H:/マイドライブ/apps/sansu-kore
   firebase init firestore
   # プロジェクト選択: your-wish-education
   ```

4. **ルールをデプロイ**
   ```bash
   firebase deploy --only firestore:rules
   ```

---

## ✅ デプロイ後の確認

### ルール動作テスト（Firebase Console）

1. **Firestore → テスト** タブ
2. **テストルール** をクリック

#### テストケース1: 自分のデータの読み取り

```
コレクション: users
ドキュメント ID: [テスト用 UID]
操作: read
認証状態: テストユーザー（上記 UID）

期待値: ✅ 許可
```

#### テストケース2: 他人のデータへのアクセス（拒否）

```
コレクション: users
ドキュメント ID: [別の UID]
操作: read
認証状態: テストユーザー（異なる UID）

期待値: ❌ 拒否
```

#### テストケース3: 公開データの読み取り

```
コレクション: leaderboards
ドキュメント ID: [任意]
操作: read
認証状態: テストユーザー

期待値: ✅ 許可
```

---

## 🔒 本番環境チェックリスト

- [ ] Firestore ルールをデプロイ済み
- [ ] テストルールで動作確認
- [ ] Cloud Functions が正しく動作するか確認
- [ ] ユーザー認証が有効か確認
- [ ] APK でログイン〜データ保存をテスト

---

## ⚠️ 注意事項

### セキュリティリスク

- **過度に緩いルール**: テスト用 `allow read, write: if true;` は本番で使用厳禁
- **Cloud Functions の実行権限**: 管理権限が必要な場合は、カスタム Claims を使用

### パフォーマンス

- **インデックス**: クエリが遅い場合、自動提案されたインデックスを作成
- **バッチ書き込み**: 大量更新時は Cloud Functions で実行

---

## 🔄 ルール更新の流れ

1. **ローカルで編集**: `firebase/firestore.rules`
2. **テスト**: Firebase Emulator Suite
   ```bash
   firebase emulators:start
   ```
3. **本番にデプロイ**: Firebase CLI または Console
4. **動作確認**: テストケース実行

---

## 📞 トラブルシューティング

### ルールデプロイ失敗時

```
Error: Compilation error in rules. [Details...]
```

→ ルールの構文を確認（括弧、セミコロン等）

### ユーザーがアクセス拒否を受ける

1. ユーザーが認証済みか確認
2. UID が正しいか確認
3. ルールのコレクションパスが正しいか確認

---

**次のステップ**: Cloud Functions の設定とデプロイ

