// Sound & Audio Model - Manages sound effects and audio settings
// Features: Sound effects, volume control, mute toggle, audio presets

enum SoundEffect {
  correct,      // 正解時の音
  incorrect,    // 不正解時の音
  perfect,      // パーフェクト時の音
  levelUp,      // レベルアップ時の音
  streakMilestone, // ストリーク達成時の音
  buttonTap,    // ボタンタップ音
  notification, // 通知音
  achievement,  // 実績解除音
}

/// Sound effect configuration
class SoundEffectConfig {
  final SoundEffect type;
  final String assetPath;
  final double defaultVolume;
  final Duration duration;
  final String description;

  const SoundEffectConfig({
    required this.type,
    required this.assetPath,
    required this.defaultVolume,
    required this.duration,
    required this.description,
  });

  /// Get all built-in sound effects
  static const List<SoundEffectConfig> allSounds = [
    SoundEffectConfig(
      type: SoundEffect.correct,
      assetPath: 'assets/sounds/correct.mp3',
      defaultVolume: 0.8,
      duration: Duration(milliseconds: 500),
      description: '正解時のチャイム音',
    ),
    SoundEffectConfig(
      type: SoundEffect.incorrect,
      assetPath: 'assets/sounds/incorrect.mp3',
      defaultVolume: 0.7,
      duration: Duration(milliseconds: 400),
      description: '不正解時の音',
    ),
    SoundEffectConfig(
      type: SoundEffect.perfect,
      assetPath: 'assets/sounds/perfect.mp3',
      defaultVolume: 0.9,
      duration: Duration(milliseconds: 1000),
      description: 'パーフェクト時のファンファーレ',
    ),
    SoundEffectConfig(
      type: SoundEffect.levelUp,
      assetPath: 'assets/sounds/level_up.mp3',
      defaultVolume: 0.8,
      duration: Duration(milliseconds: 800),
      description: 'レベルアップ時の音',
    ),
    SoundEffectConfig(
      type: SoundEffect.streakMilestone,
      assetPath: 'assets/sounds/streak_milestone.mp3',
      defaultVolume: 0.85,
      duration: Duration(milliseconds: 900),
      description: 'ストリーク達成時の音',
    ),
    SoundEffectConfig(
      type: SoundEffect.buttonTap,
      assetPath: 'assets/sounds/button_tap.mp3',
      defaultVolume: 0.5,
      duration: Duration(milliseconds: 100),
      description: 'ボタンタップ音',
    ),
    SoundEffectConfig(
      type: SoundEffect.notification,
      assetPath: 'assets/sounds/notification.mp3',
      defaultVolume: 0.7,
      duration: Duration(milliseconds: 300),
      description: 'デイリーチャレンジ通知音',
    ),
    SoundEffectConfig(
      type: SoundEffect.achievement,
      assetPath: 'assets/sounds/achievement.mp3',
      defaultVolume: 0.9,
      duration: Duration(milliseconds: 1200),
      description: 'バッジ/実績解除音',
    ),
  ];

  /// Get config for specific sound type
  static SoundEffectConfig? getConfig(SoundEffect type) {
    try {
      return allSounds.firstWhere((s) => s.type == type);
    } catch (e) {
      return null;
    }
  }
}

/// Audio settings state
class AudioSettings {
  final bool soundEnabled;
  final bool hapticEnabled;
  final double masterVolume; // 0.0 to 1.0
  final double effectVolume; // 0.0 to 1.0
  final bool muteInQuietHours; // 夜間(22:00-8:00)にミュート

  const AudioSettings({
    this.soundEnabled = true,
    this.hapticEnabled = true,
    this.masterVolume = 1.0,
    this.effectVolume = 1.0,
    this.muteInQuietHours = true,
  });

  /// Create settings with modifications
  AudioSettings copyWith({
    bool? soundEnabled,
    bool? hapticEnabled,
    double? masterVolume,
    double? effectVolume,
    bool? muteInQuietHours,
  }) {
    return AudioSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      masterVolume: masterVolume ?? this.masterVolume,
      effectVolume: effectVolume ?? this.effectVolume,
      muteInQuietHours: muteInQuietHours ?? this.muteInQuietHours,
    );
  }

  /// Validate volume values (0.0-1.0)
  bool get isValid => masterVolume >= 0.0 && masterVolume <= 1.0 &&
                      effectVolume >= 0.0 && effectVolume <= 1.0;

  /// Get combined volume (master × effect)
  double getEffectiveVolume() => masterVolume * effectVolume;

  /// Check if should mute based on quiet hours
  bool shouldMuteForQuietHours() {
    if (!muteInQuietHours) return false;

    final now = DateTime.now();
    final hour = now.hour;

    // 22:00 (22) to 8:00 (8) - quiet hours
    return hour >= 22 || hour < 8;
  }

  /// Check if sound should actually play
  bool shouldPlaySound() {
    return soundEnabled && !shouldMuteForQuietHours();
  }
}

/// Sound playback state
class SoundPlaybackState {
  final bool isPlaying;
  final SoundEffect? currentSound;
  final DateTime? startedAt;
  final String? error;

  const SoundPlaybackState({
    this.isPlaying = false,
    this.currentSound,
    this.startedAt,
    this.error,
  });

  SoundPlaybackState copyWith({
    bool? isPlaying,
    SoundEffect? currentSound,
    DateTime? startedAt,
    String? error,
  }) {
    return SoundPlaybackState(
      isPlaying: isPlaying ?? this.isPlaying,
      currentSound: currentSound ?? this.currentSound,
      startedAt: startedAt ?? this.startedAt,
      error: error,
    );
  }
}

/// Sound preset configurations
class SoundPreset {
  final String name;
  final String description;
  final AudioSettings settings;

  const SoundPreset({
    required this.name,
    required this.description,
    required this.settings,
  });

  /// Pre-defined presets
  static const List<SoundPreset> presets = [
    SoundPreset(
      name: 'Default',
      description: '標準設定 - すべてのサウンド有効',
      settings: AudioSettings(
        soundEnabled: true,
        hapticEnabled: true,
        masterVolume: 1.0,
        effectVolume: 1.0,
        muteInQuietHours: false,
      ),
    ),
    SoundPreset(
      name: 'Quiet',
      description: 'サイレント - サウンドとハプティクス無効',
      settings: AudioSettings(
        soundEnabled: false,
        hapticEnabled: false,
        masterVolume: 0.0,
        effectVolume: 0.0,
        muteInQuietHours: true,
      ),
    ),
    SoundPreset(
      name: 'School Mode',
      description: '学校モード - ボタン音のみ',
      settings: AudioSettings(
        soundEnabled: true,
        hapticEnabled: true,
        masterVolume: 0.3,
        effectVolume: 0.5,
        muteInQuietHours: true,
      ),
    ),
    SoundPreset(
      name: 'Focus',
      description: 'フォーカス - 必要な音のみ',
      settings: AudioSettings(
        soundEnabled: true,
        hapticEnabled: true,
        masterVolume: 0.6,
        effectVolume: 0.7,
        muteInQuietHours: true,
      ),
    ),
    SoundPreset(
      name: 'Celebration',
      description: 'お祝いモード - すべてのサウンド有効',
      settings: AudioSettings(
        soundEnabled: true,
        hapticEnabled: true,
        masterVolume: 1.0,
        effectVolume: 1.0,
        muteInQuietHours: false,
      ),
    ),
  ];

  /// Get preset by name
  static SoundPreset? getPreset(String name) {
    try {
      return presets.firstWhere((p) => p.name == name);
    } catch (e) {
      return null;
    }
  }
}
