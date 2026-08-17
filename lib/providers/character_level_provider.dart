/// キャラクターの画像パス解決ヘルパー
///
/// レベルの実データは `characterStateProvider`（shared_core）が
/// 唯一のソース・オブ・トゥルース。ここでは画像パス組み立てのみ行う。

/// キャラクターIDからTierを取得するヘルパー関数
int getTierByCharacterId(String characterId) {
  const tierMap = {
    // Tier 1
    'ichiko': 1,
    'niniko': 1,
    'trai': 1,
    'fouku': 1,
    // Tier 2
    'gogo': 2,
    'plaruga': 2,
    'foxmy': 2,
    'multiko': 2,
    'divido': 2,
    // Tier 3
    'geome': 3,
    'calcuku': 3,
    'fukuju': 3,
    // Tier 4
    'plus_minus': 4,
  };
  return tierMap[characterId] ?? 1;
}

/// キャラクターのレベル画像パスを取得
String getCharacterImagePath(String characterId, int level) {
  final validLevel = level.clamp(1, 5);
  final tier = getTierByCharacterId(characterId);
  return 'assets/characters/tier$tier/$characterId/${characterId}_lv${validLevel}_normal.png';
}
