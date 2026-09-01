import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import '../data/sansu_characters.dart';
import '../providers/character_shop_provider.dart';

// ── 算数コレ 交換所アイテム ──────────────────────────────────────────────
// 2026-07: 交換所・期間限定タブはいったん非表示（ラインナップ見直し中）。
// 復活する際は _exchangeItems / _seasonalItems をそのまま CoinShopPage に渡す。

// ignore: unused_element
const _exchangeItemsArchive = [
  AppShopItem(id: 'hat_number',    emoji: '🔢', name: '数字帽子',
      description: 'キャラに数字の帽子をかぶせる', category: '帽子', coinCost: 80),
  AppShopItem(id: 'hat_abacus',    emoji: '🧮', name: 'そろばん帽',
      description: '計算名人のそろばん帽子', category: '帽子', coinCost: 100),
  AppShopItem(id: 'hat_graduate',  emoji: '🎓', name: '算数博士帽',
      description: '算数マスターの証の博士帽', category: '帽子', coinCost: 120),
  AppShopItem(id: 'bg_chalkboard', emoji: '📋', name: '黒板の背景',
      description: '計算式が書かれた黒板背景', category: '背景', coinCost: 200),
  AppShopItem(id: 'bg_space_math', emoji: '🌌', name: '数式宇宙',
      description: '数式が浮かぶ宇宙の背景', category: '背景', coinCost: 200),
  AppShopItem(id: 'bg_geometry',   emoji: '📐', name: '幾何学模様',
      description: '美しい図形が並ぶ背景', category: '背景', coinCost: 200),
  AppShopItem(id: 'bgm_focus',     emoji: '🎵', name: '集中BGM',
      description: '計算に集中できる静かなBGM', category: 'BGM', coinCost: 150),
  AppShopItem(id: 'bgm_exciting',  emoji: '🎶', name: 'わくわくBGM',
      description: '算数がたのしくなるBGM', category: 'BGM', coinCost: 150),
  AppShopItem(id: 'frame_calc',    emoji: '✖️', name: '計算記号フレーム',
      description: '+−×÷が並ぶフレーム', category: 'フレーム', coinCost: 200),
  AppShopItem(id: 'frame_gold',    emoji: '🏆', name: 'ゴールドフレーム',
      description: '算数王者の金色フレーム', category: 'フレーム', coinCost: 250),
  AppShopItem(id: 'stamp_coupon_sansu', emoji: '🎁',
      name: 'LINEスタンプ無料引換券',
      description: '算数コレキャラのスタンプ1セットが無料！',
      category: 'スペシャル', coinCost: 1000),
];

// ── 算数コレ 期間限定アイテム ─────────────────────────────────────────────

// ignore: unused_element
const _seasonalItemsArchive = <String, List<AppShopItem>>{
  'spring': [
    AppShopItem(id: 'bg_spring_math', emoji: '🌸', name: '春の数式背景',
        description: '桜と数式が舞う春の背景', category: '期間限定', coinCost: 300),
    AppShopItem(id: 'frame_entrance_sansu', emoji: '🎒', name: '新学期フレーム',
        description: '新年度の算数スタートを飾る', category: '期間限定', coinCost: 200),
    AppShopItem(id: 'hat_flower_num', emoji: '🌷', name: '数字お花帽子',
        description: '春の花に数字が咲いている', category: '期間限定', coinCost: 150),
  ],
  'summer': [
    AppShopItem(id: 'bg_summer_calc', emoji: '🎆', name: '花火カウント',
        description: '花火が数字でカウントダウン', category: '期間限定', coinCost: 300),
    AppShopItem(id: 'hat_sun_number', emoji: '☀️', name: '太陽数字帽',
        description: '夏の太陽に数字が輝く', category: '期間限定', coinCost: 100),
    AppShopItem(id: 'effect_bubbles', emoji: '🫧', name: '数字バブル',
        description: '数字が入った泡が浮かぶ', category: '期間限定', coinCost: 250),
  ],
  'autumn': [
    AppShopItem(id: 'bg_autumn_graph', emoji: '🍁', name: '秋のグラフ背景',
        description: '紅葉が棒グラフ状に並ぶ', category: '期間限定', coinCost: 300),
    AppShopItem(id: 'frame_study',   emoji: '📚', name: '読書の秋フレーム',
        description: '算数と読書の秋フレーム', category: '期間限定', coinCost: 200),
    AppShopItem(id: 'hat_mushroom_num', emoji: '🍄', name: '数字キノコ帽',
        description: '秋の森のキノコに数字が', category: '期間限定', coinCost: 120),
  ],
  'winter': [
    AppShopItem(id: 'bg_snow_formula', emoji: '❄️', name: '雪の数式背景',
        description: '雪の結晶に数式が輝く', category: '期間限定', coinCost: 300),
    AppShopItem(id: 'hat_santa_calc', emoji: '🎅', name: 'サンタ計算帽',
        description: 'サンタの帽子に計算式が', category: '期間限定', coinCost: 150),
    AppShopItem(id: 'frame_newyear_sansu', emoji: '🎍', name: '算数お正月フレーム',
        description: '新年の抱負は算数！', category: '期間限定', coinCost: 200),
    AppShopItem(id: 'effect_snow_num', emoji: '🌨️', name: '数字の雪',
        description: '数字が雪のように降ってくる', category: '期間限定', coinCost: 200),
  ],
};

// ── ShopScreen ────────────────────────────────────────────────────────────

/// 算数コレ版ショップ。
/// キャラクター購入機能を統合。
class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleCharacterPurchase(String characterId) async {
    final coinState = ref.read(coinProvider);
    final currentCoins = coinState.totalCoins;
    final characterShopNotifier = ref.read(characterShopProvider.notifier);
    final price = characterShopNotifier.getCharacterPrice(characterId);

    if (price == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('このキャラクターは購入できません。'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (currentCoins < price) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('コインが不足しています。あと${price - currentCoins}コイン必要です。'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // キャラクター購入処理
    final success = await characterShopNotifier.purchaseCharacter(characterId, currentCoins);

    if (success && mounted) {
      // コイン減額処理
      await ref.read(coinProvider.notifier).spendCoins(price);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$characterIdを購入しました！($price コイン使用)'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // UIを更新するために状態を再構築
      setState(() {});
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('購入に失敗しました。既に購入済みの可能性があります。'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final characterShopState = ref.watch(characterShopProvider);
    final coinState = ref.watch(coinProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ショップ'),
        backgroundColor: Colors.blue.shade700,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'キャラクター'),
            Tab(text: 'アイテム'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // キャラクター購入タブ
          _CharacterShopTab(
            characters: kSansuCharacters,
            characterShopState: characterShopState,
            currentCoins: coinState.totalCoins,
            onPurchase: _handleCharacterPurchase,
          ),
          // アイテム購入タブ（共有コアのCoinShopPageを使用）
          CoinShopPage(
            characters: const [],
            exchangeItems: const [],
            seasonalItems: const {},
          ),
        ],
      ),
    );
  }
}

/// キャラクター購入タブ
class _CharacterShopTab extends StatelessWidget {
  final List<BaseCharacter> characters;
  final CharacterShopState characterShopState;
  final int currentCoins;
  final Future<void> Function(String characterId) onPurchase;

  const _CharacterShopTab({
    required this.characters,
    required this.characterShopState,
    required this.currentCoins,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    // Tier別にキャラクターを分類
    final tier1Chars = characters.where((c) => c.tier == 1).toList();
    final tier2Chars = characters.where((c) => c.tier == 2).toList();
    final tier3Chars = characters.where((c) => c.tier == 3).toList();
    final tier4Chars = characters.where((c) => c.tier == 4).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tier 1: 無料キャラクター
          _CharacterTierSection(
            title: 'Tier 1: はじめての算数 (無料)',
            characters: tier1Chars,
            characterShopState: characterShopState,
            currentCoins: currentCoins,
            onPurchase: onPurchase,
            isPurchasable: false,
          ),
          // Tier 2: 購入キャラクター
          if (tier2Chars.isNotEmpty)
            _CharacterTierSection(
              title: 'Tier 2: 計算の達人 (150コイン)',
              characters: tier2Chars,
              characterShopState: characterShopState,
              currentCoins: currentCoins,
              onPurchase: onPurchase,
              isPurchasable: true,
            ),
          // Tier 3: 購入キャラクター
          if (tier3Chars.isNotEmpty)
            _CharacterTierSection(
              title: 'Tier 3: 図形と量の世界 (200コイン)',
              characters: tier3Chars,
              characterShopState: characterShopState,
              currentCoins: currentCoins,
              onPurchase: onPurchase,
              isPurchasable: true,
            ),
          // Tier 4: 伝説の存在
          if (tier4Chars.isNotEmpty)
            _CharacterTierSection(
              title: 'Tier 4: 伝説の存在 (レア)',
              characters: tier4Chars,
              characterShopState: characterShopState,
              currentCoins: currentCoins,
              onPurchase: onPurchase,
              isPurchasable: true,
            ),
        ],
      ),
    );
  }
}

/// Tier別キャラクターセクション
class _CharacterTierSection extends StatelessWidget {
  final String title;
  final List<BaseCharacter> characters;
  final CharacterShopState characterShopState;
  final int currentCoins;
  final Future<void> Function(String characterId) onPurchase;
  final bool isPurchasable;

  const _CharacterTierSection({
    required this.title,
    required this.characters,
    required this.characterShopState,
    required this.currentCoins,
    required this.onPurchase,
    required this.isPurchasable,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85,
            crossAxisSpacing: 8,
            mainAxisSpacing: 12,
          ),
          itemCount: characters.length,
          itemBuilder: (context, index) {
            final character = characters[index];
            return _CharacterShopCard(
              character: character,
              isPurchased: characterShopState.purchasedCharacterIds.contains(character.id),
              isPurchasable: isPurchasable,
              currentCoins: currentCoins,
              onPurchase: onPurchase,
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// キャラクター購入カード
class _CharacterShopCard extends ConsumerWidget {
  final BaseCharacter character;
  final bool isPurchased;
  final bool isPurchasable;
  final int currentCoins;
  final Future<void> Function(String characterId) onPurchase;

  const _CharacterShopCard({
    required this.character,
    required this.isPurchased,
    required this.isPurchasable,
    required this.currentCoins,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final price = ref.read(characterShopProvider.notifier).getCharacterPrice(character.id);
    final canAfford = price == null || currentCoins >= price;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // キャラクター情報
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        character.emoji,
                        style: const TextStyle(fontSize: 48),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        character.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        character.subject,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              // 購入ボタンまたはステータス
              if (!isPurchasable)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'アンロック済み',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else if (isPurchased)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '購入済み',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: ElevatedButton(
                    onPressed: canAfford
                        ? () => onPurchase(character.id)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canAfford ? Colors.blue : Colors.grey,
                      disabledBackgroundColor: Colors.grey.shade300,
                      minimumSize: const Size(double.infinity, 36),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      '${price}コイン',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // ロックアイコン（未購入の場合）
          if (isPurchasable && !isPurchased)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red.shade600,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '🔒',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
