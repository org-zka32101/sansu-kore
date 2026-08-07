# Firestore ルール デプロイ（手動）

**所要時間**: 2分

---

## 📝 デプロイ手順

### 1️⃣ ルール内容をコピー

ファイルを開く:
```
H:\マイドライブ\apps\sansu-kore\firebase\firestore.rules
```

**全文をコピーしてください** （Ctrl+A → Ctrl+C）

---

### 2️⃣ Firebase Console を開く

ブラウザで開く:
```
https://console.firebase.google.com/
```

ログイン: `yourwishdev@gmail.com`

---

### 3️⃣ プロジェクト選択

1. **プロジェクト選択**: `your-wish-education`
2. 左メニュー → **Firestore Database**

---

### 4️⃣ ルールを貼り付け

1. 上部 **「ルール」タブ** をクリック
2. エディタ内の既存テキストを全削除 （Ctrl+A → Delete）
3. **コピーしたルール内容を貼り付け** （Ctrl+V）

```
// こんな感じになります
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    ...
  }
}
```

---

### 5️⃣ 発行

**「発行」ボタン** をクリック

```
⏳ デプロイ中... (1〜2分待機)

✅ ルールが発行されました
```

---

## ✅ デプロイ確認

### コンソールメッセージ

```
Firestore ルール
最終更新: 2026-06-23 XX:XX:XX
バージョン: 最新
```

### テスト実行（オプション）

1. **「テスト」タブ** をクリック
2. **テストルール** → 許可/拒否が正しく動作するか確認

---

完了したら報告してください ✓

