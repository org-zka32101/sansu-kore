import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_core/shared_core.dart';
import '../data/sansu_characters.dart';

/// キャラクター購入管理
class CharacterShopState {
  final Set<String> purchasedCharacterIds;
  final int totalCoinsSpent;

  const CharacterShopState({
    this.purchasedCharacterIds = const {},
    this.totalCoinsSpent = 0,
  });

  CharacterShopState copyWith({
    Set<String>? purchasedCharacterIds,
    int? totalCoinsSpent,
  }) {
    return CharacterShopState(
      purchasedCharacterIds: purchasedCharacterIds ?? this.purchasedCharacterIds,
      totalCoinsSpent: totalCoinsSpent ?? this.totalCoinsSpent,
    );
  }
}

/// キャラクター価格設定
const Map<String, int> characterPrices = {
  // Tier 2 (5-7体目)
  'gosanko': 150,  // 5番目
  'rokuko': 150,   // 6番目
  'nanarino': 150, // 7番目

  // Tier 3 (8-10体目)
  'hachiko': 200,  // 8番目
  'kyuko': 200,    // 9番目
  'jubun': 200,    // 10番目
};

class CharacterShopNotifier extends StateNotifier<CharacterShopState> {
  CharacterShopNotifier() : super(const CharacterShopState()) {
    _loadPurchases();
  }

  Future<void> _loadPurchases() async {
    final prefs = await SharedPreferences.getInstance();
    final purchasedJson = prefs.getStringList('purchased_characters') ?? [];
    final totalSpent = prefs.getInt('character_shop_total_spent') ?? 0;

    state = state.copyWith(
      purchasedCharacterIds: purchasedJson.toSet(),
      totalCoinsSpent: totalSpent,
    );
  }

  /// キャラクターが購入可能か判定（有料キャラのみ）
  bool isPurchasableCharacter(String characterId) {
    return characterPrices.containsKey(characterId);
  }

  /// キャラクターの価格を取得
  int? getCharacterPrice(String characterId) {
    return characterPrices[characterId];
  }

  /// キャラクターが購入済みか確認
  bool isPurchased(String characterId) {
    return state.purchasedCharacterIds.contains(characterId);
  }

  /// キャラクターがアンロック可能か（最初の4体は無料でアンロック可能）
  bool canUnlock(BaseCharacter character) {
    // 最初の4体（Tier 1）は無料
    if (character.tier == 1) {
      return true;
    }

    // Tier 2以降は購入要
    return isPurchased(character.id);
  }

  /// キャラクターを購入
  Future<bool> purchaseCharacter(String characterId, int currentCoins) async {
    if (state.purchasedCharacterIds.contains(characterId)) {
      return false; // 既に購入済み
    }

    final price = characterPrices[characterId];
    if (price == null) {
      return false; // 購入不可キャラ
    }

    if (currentCoins < price) {
      return false; // コイン不足
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final newPurchased = {...state.purchasedCharacterIds, characterId};
      final newTotalSpent = state.totalCoinsSpent + price;

      await prefs.setStringList('purchased_characters', newPurchased.toList());
      await prefs.setInt('character_shop_total_spent', newTotalSpent);

      state = state.copyWith(
        purchasedCharacterIds: newPurchased,
        totalCoinsSpent: newTotalSpent,
      );

      return true;
    } catch (e) {
      if (kDebugMode) print('Error purchasing character: $e');
      return false;
    }
  }

  /// ショップアイテムとしてのキャラクターを取得
  List<AppShopItem> getCharacterShopItems() {
    return kSansuCharacters
        .where((char) => isPurchasableCharacter(char.id))
        .map((char) {
          final price = getCharacterPrice(char.id);
          final isPurchasedChar = isPurchased(char.id);

          return AppShopItem(
            id: char.id,
            emoji: char.emoji,
            name: char.name,
            description: char.backstory.split('\n').first,
            category: 'キャラクター',
            coinCost: price ?? 0,
          );
        })
        .toList();
  }
}

/// キャラクター購入 Provider
final characterShopProvider =
    StateNotifierProvider<CharacterShopNotifier, CharacterShopState>(
  (ref) {
    return CharacterShopNotifier();
  },
);
