import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sansu_kore/providers/character_shop_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CharacterShopProvider Tests', () {
    late ProviderContainer container;

    setUp(() {
      // SharedPreferencesをリセット
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('CharacterShopState initializes with empty purchases', () async {
      final state = container.read(characterShopProvider);
      expect(state.purchasedCharacterIds, isEmpty);
      expect(state.totalCoinsSpent, equals(0));
    });

    test('isPurchasableCharacter returns true for Tier 2+ characters', () async {
      final notifier = container.read(characterShopProvider.notifier);

      // Tier 2キャラクターはpurchasable
      expect(notifier.isPurchasableCharacter('gogo'), isTrue);
      expect(notifier.isPurchasableCharacter('multiko'), isTrue);
      expect(notifier.isPurchasableCharacter('divido'), isTrue);

      // Tier 3キャラクターはpurchasable
      expect(notifier.isPurchasableCharacter('geome'), isTrue);
      expect(notifier.isPurchasableCharacter('calcuku'), isTrue);

      // Tier 1キャラクターはpurchasable ではない
      expect(notifier.isPurchasableCharacter('ichiko'), isFalse);
      expect(notifier.isPurchasableCharacter('niniko'), isFalse);
      expect(notifier.isPurchasableCharacter('trai'), isFalse);
      expect(notifier.isPurchasableCharacter('fouku'), isFalse);
    });

    test('getCharacterPrice returns correct prices', () async {
      final notifier = container.read(characterShopProvider.notifier);

      // Tier 2: 150 coins
      expect(notifier.getCharacterPrice('gogo'), equals(150));
      expect(notifier.getCharacterPrice('multiko'), equals(150));
      expect(notifier.getCharacterPrice('divido'), equals(150));

      // Tier 3: 200 coins
      expect(notifier.getCharacterPrice('geome'), equals(200));
      expect(notifier.getCharacterPrice('calcuku'), equals(200));

      // Tier 1: null (not purchasable)
      expect(notifier.getCharacterPrice('ichiko'), isNull);
    });

    test('isPurchased returns false for new characters', () async {
      final notifier = container.read(characterShopProvider.notifier);

      expect(notifier.isPurchased('gogo'), isFalse);
      expect(notifier.isPurchased('geome'), isFalse);
    });

    test('canUnlock returns true for Tier 1 characters', () async {
      final notifier = container.read(characterShopProvider.notifier);

      // Create mock BaseCharacter instances
      final tier1Char = _createMockCharacter('ichiko', tier: 1);
      expect(notifier.canUnlock(tier1Char), isTrue);
    });

    test('canUnlock returns false for unpurchased Tier 2+ characters', () async {
      final notifier = container.read(characterShopProvider.notifier);

      final tier2Char = _createMockCharacter('gogo', tier: 2);
      expect(notifier.canUnlock(tier2Char), isFalse);
    });

    test('purchaseCharacter fails with insufficient coins', () async {
      final notifier = container.read(characterShopProvider.notifier);

      final success = await notifier.purchaseCharacter('gogo', 100); // Need 150
      expect(success, isFalse);

      // Verify state didn't change
      final state = container.read(characterShopProvider);
      expect(state.purchasedCharacterIds, isEmpty);
      expect(state.totalCoinsSpent, equals(0));
    });

    test('purchaseCharacter succeeds with sufficient coins', () async {
      final notifier = container.read(characterShopProvider.notifier);

      final success = await notifier.purchaseCharacter('gogo', 200); // Need 150
      expect(success, isTrue);

      // Verify state changed
      final state = container.read(characterShopProvider);
      expect(state.purchasedCharacterIds, contains('gogo'));
      expect(state.totalCoinsSpent, equals(150));
      expect(notifier.isPurchased('gogo'), isTrue);
    });

    test('purchaseCharacter prevents duplicate purchases', () async {
      final notifier = container.read(characterShopProvider.notifier);

      // First purchase
      final success1 = await notifier.purchaseCharacter('gogo', 200);
      expect(success1, isTrue);

      // Second purchase of same character
      final success2 = await notifier.purchaseCharacter('gogo', 200);
      expect(success2, isFalse); // Should fail

      // Verify state only changed once
      final state = container.read(characterShopProvider);
      expect(state.purchasedCharacterIds.length, equals(1));
      expect(state.totalCoinsSpent, equals(150)); // Only one purchase
    });

    test('purchaseCharacter persists to SharedPreferences', () async {
      final notifier = container.read(characterShopProvider.notifier);

      await notifier.purchaseCharacter('gogo', 200);

      // Verify SharedPreferences was updated
      final prefs = await SharedPreferences.getInstance();
      final purchased = prefs.getStringList('purchased_characters') ?? [];
      expect(purchased, contains('gogo'));
      expect(prefs.getInt('character_shop_total_spent'), equals(150));
    });

    test('getCharacterShopItems returns correct shop items', () async {
      final notifier = container.read(characterShopProvider.notifier);

      final shopItems = notifier.getCharacterShopItems();

      // Should contain all purchasable characters
      expect(shopItems.any((item) => item.id == 'gogo'), isTrue);
      expect(shopItems.any((item) => item.id == 'geome'), isTrue);

      // Should NOT contain Tier 1 characters
      expect(shopItems.any((item) => item.id == 'ichiko'), isFalse);

      // Verify prices
      final gogoItem = shopItems.firstWhere((item) => item.id == 'gogo');
      expect(gogoItem.coinCost, equals(150));
    });

    test('Multiple purchases accumulate correctly', () async {
      final notifier = container.read(characterShopProvider.notifier);

      // Purchase first character
      await notifier.purchaseCharacter('gogo', 500);
      // Purchase second character
      await notifier.purchaseCharacter('multiko', 500);
      // Purchase third character
      await notifier.purchaseCharacter('geome', 500);

      final state = container.read(characterShopProvider);
      expect(state.purchasedCharacterIds.length, equals(3));
      expect(state.totalCoinsSpent, equals(150 + 150 + 200)); // 500 total
    });
  });
}

/// Mock BaseCharacter for testing
class _MockCharacter implements BaseCharacter {
  @override
  final String id;
  @override
  final String name;
  @override
  final String emoji;
  @override
  final int tier;
  @override
  final int unlockAt;
  @override
  final String imageAsset;
  @override
  final Map<int, String> levelImages;
  @override
  final String subject;
  @override
  final String backstory;
  @override
  final List<String> stampPhrases;

  _MockCharacter({
    required this.id,
    required this.name,
    required this.emoji,
    required this.tier,
    required this.unlockAt,
    required this.imageAsset,
    required this.levelImages,
    required this.subject,
    required this.backstory,
    required this.stampPhrases,
  });
}

BaseCharacter _createMockCharacter(String id, {int tier = 1}) {
  return _MockCharacter(
    id: id,
    name: 'Test $id',
    emoji: '🎨',
    tier: tier,
    unlockAt: 0,
    imageAsset: 'assets/test.png',
    levelImages: const {},
    subject: 'Test',
    backstory: 'Test backstory',
    stampPhrases: const ['test'],
  );
}
