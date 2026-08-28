import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// ── AdsProvider: バナー・インタースティシャル広告管理 ────────────────────────────

class AdsNotifier extends StateNotifier<AdsState> {
  AdsNotifier() : super(const AdsState());

  // バナー広告の読み込み
  Future<void> loadBannerAd() async {
    try {
      state = state.copyWith(bannerLoading: true);

      final bannerAd = BannerAd(
        adUnitId: _bannerAdUnitId,
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

  // インタースティシャル広告の読み込み
  Future<void> loadInterstitialAd() async {
    try {
      state = state.copyWith(interstitialLoading: true);

      InterstitialAd.load(
        adUnitId: _interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            state = state.copyWith(
              interstitialAd: ad,
              interstitialLoading: false,
              interstitialError: null,
            );
          },
          onAdFailedToLoad: (error) {
            state = state.copyWith(
              interstitialLoading: false,
              interstitialError: error.message,
            );
          },
        ),
      );
    } catch (e) {
      state = state.copyWith(
        interstitialLoading: false,
        interstitialError: e.toString(),
      );
    }
  }

  // インタースティシャル広告を表示
  void showInterstitialAd({
    required void Function() onAdDismissed,
  }) {
    final ad = state.interstitialAd;
    if (ad == null) {
      onAdDismissed();
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {},
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        state = state.copyWith(interstitialAd: null);
        onAdDismissed();
        // 次の広告を読み込む
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        state = state.copyWith(interstitialAd: null);
        onAdDismissed();
        // 次の広告を読み込む
        loadInterstitialAd();
      },
    );

    ad.show();
  }

  // バナー広告をクリア
  void disposeBannerAd() {
    state.bannerAd?.dispose();
    state = state.copyWith(bannerAd: null);
  }

  // インタースティシャル広告をクリア
  void disposeInterstitialAd() {
    state.interstitialAd?.dispose();
    state = state.copyWith(interstitialAd: null);
  }

  @override
  void dispose() {
    disposeBannerAd();
    disposeInterstitialAd();
    super.dispose();
  }
}

class AdsState {
  final BannerAd? bannerAd;
  final bool bannerLoading;
  final String? bannerError;
  final InterstitialAd? interstitialAd;
  final bool interstitialLoading;
  final String? interstitialError;

  const AdsState({
    this.bannerAd,
    this.bannerLoading = false,
    this.bannerError,
    this.interstitialAd,
    this.interstitialLoading = false,
    this.interstitialError,
  });

  AdsState copyWith({
    BannerAd? bannerAd,
    bool? bannerLoading,
    String? bannerError,
    InterstitialAd? interstitialAd,
    bool? interstitialLoading,
    String? interstitialError,
  }) {
    return AdsState(
      bannerAd: bannerAd ?? this.bannerAd,
      bannerLoading: bannerLoading ?? this.bannerLoading,
      bannerError: bannerError ?? this.bannerError,
      interstitialAd: interstitialAd ?? this.interstitialAd,
      interstitialLoading: interstitialLoading ?? this.interstitialLoading,
      interstitialError: interstitialError ?? this.interstitialError,
    );
  }
}

// ── Google AdMob Ad Unit ID ────────────────────────────────────────────
// sansu-kore アプリ用 ID
const String _bannerAdUnitId = 'ca-app-pub-5058227312086483/7662073953';
const String _interstitialAdUnitId = 'ca-app-pub-5058227312086483/XXXXXXXXXX'; // TODO: インタースティシャル広告のユニットIDを設定

// ── Riverpod Provider ─────────────────────────────────────────────
final adsProvider = StateNotifierProvider<AdsNotifier, AdsState>((ref) {
  return AdsNotifier();
});
