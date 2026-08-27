import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// ── AdsProvider: バナー・リワード広告管理 ────────────────────────────

class AdsNotifier extends StateNotifier<AdsState> {
  AdsNotifier() : super(const AdsState());

  // バナー広告の読み込み
  Future<void> loadBannerAd() async {
    try {
      state = state.copyWith(bannerLoading: true);

      final bannerAd = BannerAd(
        adUnitId: _testBannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            state = state.copyWith(
              bannerAd: ad as BannerAd,
              bannerLoading: false,
              bannerError: null,
            );
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            state = state.copyWith(
              bannerLoading: false,
              bannerError: error.message,
            );
          },
        ),
      );

      await bannerAd.load();
    } catch (e) {
      state = state.copyWith(
        bannerLoading: false,
        bannerError: e.toString(),
      );
    }
  }

  // リワード広告の読み込み
  Future<void> loadRewardedAd() async {
    try {
      state = state.copyWith(rewardedLoading: true);

      RewardedAd.load(
        adUnitId: _testRewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            state = state.copyWith(
              rewardedAd: ad,
              rewardedLoading: false,
              rewardedError: null,
            );
          },
          onAdFailedToLoad: (error) {
            state = state.copyWith(
              rewardedLoading: false,
              rewardedError: error.message,
            );
          },
        ),
      );
    } catch (e) {
      state = state.copyWith(
        rewardedLoading: false,
        rewardedError: e.toString(),
      );
    }
  }

  // リワード広告を表示（ユーザーが報酬を獲得できる）
  void showRewardedAd({
    required void Function(AdWithoutView ad, RewardItem reward) onUserEarnedReward,
    required void Function() onAdDismissed,
  }) {
    final ad = state.rewardedAd;
    if (ad == null) {
      onAdDismissed();
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {},
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        state = state.copyWith(rewardedAd: null);
        onAdDismissed();
        // 次の広告を読み込む
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        state = state.copyWith(rewardedAd: null);
        onAdDismissed();
        // 次の広告を読み込む
        loadRewardedAd();
      },
    );

    ad.show(
      onUserEarnedReward: onUserEarnedReward,
    );
  }

  // バナー広告をクリア
  void disposeBannerAd() {
    state.bannerAd?.dispose();
    state = state.copyWith(bannerAd: null);
  }

  // リワード広告をクリア
  void disposeRewardedAd() {
    state.rewardedAd?.dispose();
    state = state.copyWith(rewardedAd: null);
  }

  @override
  void dispose() {
    disposeBannerAd();
    disposeRewardedAd();
    super.dispose();
  }
}

class AdsState {
  final BannerAd? bannerAd;
  final bool bannerLoading;
  final String? bannerError;
  final RewardedAd? rewardedAd;
  final bool rewardedLoading;
  final String? rewardedError;

  const AdsState({
    this.bannerAd,
    this.bannerLoading = false,
    this.bannerError,
    this.rewardedAd,
    this.rewardedLoading = false,
    this.rewardedError,
  });

  AdsState copyWith({
    BannerAd? bannerAd,
    bool? bannerLoading,
    String? bannerError,
    RewardedAd? rewardedAd,
    bool? rewardedLoading,
    String? rewardedError,
  }) {
    return AdsState(
      bannerAd: bannerAd ?? this.bannerAd,
      bannerLoading: bannerLoading ?? this.bannerLoading,
      bannerError: bannerError ?? this.bannerError,
      rewardedAd: rewardedAd ?? this.rewardedAd,
      rewardedLoading: rewardedLoading ?? this.rewardedLoading,
      rewardedError: rewardedError ?? this.rewardedError,
    );
  }
}

// ── テスト用 AdUnit ID ────────────────────────────────────────────
// 実運用時は Google AdMob の実ID に置き換える
const String _testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
const String _testRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

// ── Riverpod Provider ─────────────────────────────────────────────
final adsProvider = StateNotifierProvider<AdsNotifier, AdsState>((ref) {
  return AdsNotifier();
});
