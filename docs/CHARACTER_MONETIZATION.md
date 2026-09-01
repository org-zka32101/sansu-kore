# キャラクター購入システム - 実装ガイド

## 概要

算数コレのキャラクター購入システムは、ユーザーがコイン（ゲーム内通貨）を使用してゲームキャラクターを購入・アンロックするメカニズムです。

**基本ルール:**
- **Tier 1** (最初の4体): 完全に無料 - ユーザーはプレイ開始直後から利用可能
- **Tier 2** (5-7番目): 150コイン/キャラクター
- **Tier 3** (8-9番目): 200コイン/キャラクター
- **Tier 4** (伝説の存在): 要カスタマイズ

---

## ファイル構成

### `lib/providers/character_shop_provider.dart`
キャラクター購入システムの中核。Riverpodを使用したStateNotifier実装。

**クラス:**
- `CharacterShopState`: 購入状態を管理（購入済みキャラID、総コイン使用量）
- `CharacterShopNotifier`: ビジネスロジック（購入、検証、永続化）

**主要メソッド:**
```dart
// キャラクターが購入可能か判定
bool isPurchasableCharacter(String characterId)

// キャラクターの価格を取得
int? getCharacterPrice(String characterId)

// キャラクターが購入済みか確認
bool isPurchased(String characterId)

// キャラクターがアンロック可能か（Tier 1は常に可能）
bool canUnlock(BaseCharacter character)

// キャラクター購入（コイン検証含む）
Future<bool> purchaseCharacter(String characterId, int currentCoins)

// ショップアイテム一覧を生成
List<AppShopItem> getCharacterShopItems()
```

**状態永続化:**
- `SharedPreferences`を使用してローカルに保存
- `purchased_characters`: 購入済みキャラのID一覧（JSON配列）
- `character_shop_total_spent`: 総使用コイン数

---

### `lib/screens/shop_screen.dart`
キャラクター購入UIの実装。複数タブで構成。

**機能:**
1. **キャラクター購入タブ**
   - Tier別にキャラクターを分類表示
   - 購入状態に応じて異なるUIを表示:
     - Tier 1: 「アンロック済み」バッジ
     - Tier 2+未購入: 購入ボタン + ロックアイコン 🔒
     - Tier 2+購入済み: 「購入済み」バッジ
   
2. **アイテム購入タブ**
   - 共有コア（`shared_core`）のCoinShopPageを利用

**購入フロー:**
```
ユーザーが購入ボタンをクリック
  ↓
コイン残高確認
  ↓
不足: エラーメッセージ
足りる: purchaseCharacter()を呼び出し
  ↓
購入成功 → コイン減額 + 状態更新 → 成功メッセージ
購入失敗 → エラーメッセージ
```

---

### `lib/screens/character_screen.dart`
キャラクター図鑑画面。購入システムとの連携。

**機能:**
- CharacterCollectionPageから購入ステータスを監視
- 新しい購入があった場合、UI自動更新

---

## 統合ポイント

### 1. コイン システムとの連携

```dart
// ShopScreenで購入後
final coinProvider = ref.read(coinProvider);
await ref.read(coinProvider.notifier).spendCoins(price);
```

**必須条件:**
- `coinProvider`がコイン減額をサポート必要
- `spendCoins(int amount)`メソッド実装必要

### 2. Firebase Firestoreとの連携（オプション）

将来、サーバー側でもキャラクター購入記録を同期する場合:

```dart
await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('purchased_characters')
    .add({
      'characterId': characterId,
      'purchasedAt': FieldValue.serverTimestamp(),
      'priceCoins': price,
    });
```

### 3. リーダーボード/ランキングシステム

購入キャラクター数でフィルタリング可能:

```dart
// 所有キャラ数
final ownedCount = characterShopState.purchasedCharacterIds.length + 4; // Tier 1は4体
```

---

## UI コンポーネント

### _CharacterShopCard
個別キャラクター表示カード。

**表示状態:**
- **未購入 (Tier 2+)**: 
  - 購入ボタン表示
  - 右上に🔒アイコン
  - コイン残高不足時はボタン無効化
  
- **購入済み (Tier 2+)**:
  - 「購入済み」バッジ表示
  - ボタンなし
  
- **無料 (Tier 1)**:
  - 「アンロック済み」バッジ表示
  - ボタンなし

---

## テスト

### ユニットテスト: `test/character_shop_provider_test.dart`

**実行方法:**
```bash
flutter test test/character_shop_provider_test.dart
```

**テスト項目:**
- 状態初期化
- Tier別のpurchasable判定
- 価格取得
- 購入バリデーション（コイン不足）
- 購入成功時の状態更新
- 重複購入防止
- SharedPreferences永続化
- canUnlock()ロジック

---

## 設定・カスタマイズ

### キャラクター価格の変更

`character_shop_provider.dart`内の`characterPrices`マップを編集:

```dart
const Map<String, int> characterPrices = {
  // Tier 2 (5-7体目)
  'gosanko': 150,   // ← 価格を変更
  'rokuko': 150,
  'nanarino': 150,

  // Tier 3 (8-10体目)
  'hachiko': 200,
  'kyuko': 200,
  'jubun': 200,
};
```

### 新しいキャラクターの追加

`lib/data/sansu_characters.dart`に新キャラを追加後:

1. `character_shop_provider.dart`の`characterPrices`に追加
2. 必要に応じてshop_screen.dartのTier区分を更新

---

## トラブルシューティング

### 問題: 購入後、コインが減額されない

**原因:** `coinProvider.notifier.spendCoins()`が未実装
**解決:** coin_provider.dartで`spendCoins()`メソッドを確認

### 問題: SharedPreferencesに保存されない

**原因:** async/awaitの誤り、権限不足
**解決:** ログでshared_preferences初期化を確認

### 問題: 購入済みキャラが画面に反映されない

**原因:** UIがcharacterShopProviderを監視していない
**解決:** `ref.watch(characterShopProvider)`を呼び出し確認

---

## 今後の拡張案

1. **マルチプレイヤー同期**
   - Firestore同期で複数デバイス間での購入状態共有

2. **リーダーボード統合**
   - 所有キャラ数をランキングスコアに反映

3. **セール/割引機能**
   - 期間限定割引キャラクター

4. **キャラクターバンドル**
   - 複数キャラクターまとめ購入割引

5. **フレンド共有**
   - 所有キャラをフレンドと交換

---

## 参考資料

- **Riverpod**: `character_shop_provider.dart`
- **SharedPreferences**: `lib/providers/character_shop_provider.dart` の `_loadPurchases()`
- **UI設計**: Material Design 3準拠、GridView実装
- **テスト**: Flutter Testing Guide

---

**最終更新:** 2026年9月1日  
**バージョン:** 1.0 (初版)
