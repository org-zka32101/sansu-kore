import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// shared_coreのprogressProviderとローカル版の競合を回避
import 'package:shared_core/shared_core.dart'
    hide progressProvider, LearningProgress, ProgressNotifier;
import '../data/sansu_characters.dart';
import '../providers/progress_provider.dart';
import '../providers/character_shop_provider.dart';

/// 算数コレ版キャラクター図鑑。
/// 購入ステータスを考慮して [CharacterCollectionPage] を表示。
class CharacterScreen extends ConsumerWidget {
  const CharacterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalStages = ref.watch(progressProvider).clearedStageIds.length;
    // 購入ステータスを監視（UI更新時に最新の状態を取得）
    ref.watch(characterShopProvider);

    return CharacterCollectionPage(
      characters: kSansuCharacters,
      totalStagesCleared: totalStages,
    );
  }
}
