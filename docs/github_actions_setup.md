# GitHub Actions 自動ビルド設定

**リポジトリ**: `sansu-kore` (プライベート)  
**アカウント**: `yourwishappsdev-hash`  
**自動化**: main push → APK 自動生成

---

## 📋 セットアップ手順

### Step 1: GitHub でプライベートリポジトリ作成

1. **GitHub にログイン**
   ```
   https://github.com/yourwishappsdev-hash
   ```

2. **新規リポジトリを作成**
   - ボタン: `New`（右上）
   - リポジトリ名: `sansu-kore`
   - 説明: `算数コレ！- Flutter Math Education App`
   - **Visibility: Private** ✅
   - Initialize: チェックなし
   - **Create repository**

---

### Step 2: ローカルコードを push

```bash
cd H:/マイドライブ/apps/sansu-kore

# リモートの削除
git remote remove origin

# 新しいリモートを追加
git remote add origin https://github.com/yourwishappsdev-hash/sansu-kore.git

# デフォルトブランチを main に変更
git branch -M main

# 初回 push
git push -u origin main
```

**ログイン時**:
- メール: yourwishdev@gmail.com
- パスワード: [GitHub パスワード]

または **Personal Access Token** を使用

---

### Step 3: GitHub Actions ワークフロー作成

1. **ローカルで以下ファイルを作成**

**ファイルパス**:
```
H:\マイドライブ\apps\sansu-kore\.github\workflows\build-apk.yml
```

**内容**:
```yaml
name: Build APK

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Set up Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.24.0'
        channel: 'stable'

    - name: Install dependencies
      run: |
        cd sansu-kore
        flutter pub get

    - name: Build APK
      run: |
        cd sansu-kore
        flutter build apk --release --no-tree-shake-icons

    - name: Upload APK
      uses: actions/upload-artifact@v3
      with:
        name: sansu-kore-apk
        path: sansu-kore/build/app/outputs/flutter-apk/app-release.apk

    - name: Create Release
      if: startsWith(github.ref, 'refs/tags/')
      uses: softprops/action-gh-release@v1
      with:
        files: sansu-kore/build/app/outputs/flutter-apk/app-release.apk
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

2. **git で追加して commit**

```bash
cd H:/マイドライブ/apps/sansu-kore

git add .github/workflows/build-apk.yml
git commit -m "Add GitHub Actions workflow for APK build"
git push origin main
```

---

### Step 4: 自動ビルド確認

1. **GitHub でリポジトリを開く**
   ```
   https://github.com/yourwishappsdev-hash/sansu-kore
   ```

2. **Actions タブをクリック**
   - ワークフローが実行中か確認
   - ✅ ビルド成功か確認

3. **アーティファクト確認**
   - Build 完了 → `Artifacts` → `sansu-kore-apk` ダウンロード
   - APK がダウンロード可能か確認

---

## 📦 毎回の更新フロー

**ローカルで開発** → **commit** → **push to main**

```bash
# 修正/追加
vim lib/screens/quest_screen.dart

# 確認
git status

# コミット
git add .
git commit -m "Fix: [説明]"

# プッシュ
git push origin main

# GitHub Actions が自動的に APK をビルド
# → Actions タブで確認
# → Artifacts から APK をダウンロード
```

---

## 🔐 Personal Access Token（推奨）

**パスワード代わりに PAT を使用**:

1. GitHub → Settings → Developer settings → Personal access tokens
2. **Generate new token**
3. Name: `sansu-kore-build`
4. Scopes: `repo` (full control of private repositories)
5. **Generate token**
6. トークンをコピー（二度と見えません）

**git で使用**:
```bash
git push origin main
# Username: yourwishappsdev-hash
# Password: [Personal Access Token をペースト]
```

---

## 📋 チェックリスト

- [ ] GitHub リポジトリ作成（プライベート）
- [ ] ローカルコード push
- [ ] .github/workflows/build-apk.yml 作成
- [ ] GitHub Actions ワークフロー実行確認
- [ ] APK アーティファクト確認
- [ ] 毎回の push で自動ビルド動作確認

---

## 🐛 トラブルシューティング

### ワークフロー失敗時

**GitHub の Actions タブ** → 失敗したワークフロー → ログ確認

よくある原因:
- `flutter pub get` 失敗 → `pubspec.yaml` 確認
- `flutter build apk` 失敗 → ローカルでビルド確認
- `shared_core` パス問題 → リポジトリ構成確認

---

**自動ビルド設定完了後**: 実機テストに戻る

