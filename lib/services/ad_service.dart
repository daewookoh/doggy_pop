import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import '../config/ad_config.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool _isInitialized = false;
  bool _isBannerAdLoaded = false;
  bool _isInterstitialAdLoaded = false;
  bool _isRewardedAdLoaded = false;

  // 게임 횟수 추적 (3회마다 전면 광고 표시)
  int _gamePlayCount = 0;
  static const int _interstitialAdInterval = 3;

  bool get isBannerAdLoaded => _isBannerAdLoaded;
  bool get isInterstitialAdLoaded => _isInterstitialAdLoaded;
  bool get isRewardedAdLoaded => _isRewardedAdLoaded;
  BannerAd? get bannerAd => _bannerAd;

  /// 게임 플레이 횟수 증가 및 전면 광고 표시 여부 반환
  bool incrementGameCountAndCheckAd() {
    _gamePlayCount++;
    if (_gamePlayCount >= _interstitialAdInterval) {
      _gamePlayCount = 0;
      return true; // 전면 광고 표시
    }
    return false;
  }

  /// 광고 SDK 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    await MobileAds.instance.initialize();

    // 테스트 디바이스 설정
    if (AdConfig.testDeviceIds.isNotEmpty) {
      MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: AdConfig.testDeviceIds),
      );
    }

    _isInitialized = true;

    if (kDebugMode) {
      print('======================================');
      print('AdService: 디버그 모드로 초기화됨');
      print('테스트 광고 ID를 사용합니다.');
      print('');
      print('📱 테스트 디바이스 ID 확인 방법:');
      print('Logcat에서 아래 메시지를 찾으세요:');
      print('"Use RequestConfiguration.Builder.setTestDeviceIds(Arrays.asList("YOUR_DEVICE_ID"))"');
      print('');
      if (AdConfig.testDeviceIds.isEmpty) {
        print('⚠️  현재 등록된 테스트 디바이스가 없습니다.');
        print('lib/config/ad_config.dart의 testDeviceIds에 추가하세요.');
      } else {
        print('✅ 등록된 테스트 디바이스: ${AdConfig.testDeviceIds.length}개');
        for (var id in AdConfig.testDeviceIds) {
          print('   - $id');
        }
      }
      print('======================================');
    }
  }

  /// 배너 광고 로드
  Future<void> loadBannerAd({
    AdSize adSize = AdSize.banner,
    Function()? onLoaded,
    Function(LoadAdError)? onFailed,
  }) async {
    await _bannerAd?.dispose();
    _isBannerAdLoaded = false;

    _bannerAd = BannerAd(
      adUnitId: AdConfig.bannerAdId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerAdLoaded = true;
          onLoaded?.call();
          if (kDebugMode) {
            print('AdService: Banner ad loaded');
          }
        },
        onAdFailedToLoad: (ad, error) {
          _isBannerAdLoaded = false;
          ad.dispose();
          _bannerAd = null;
          onFailed?.call(error);
          if (kDebugMode) {
            print('AdService: Banner ad failed to load: ${error.message}');
          }
        },
      ),
    );

    await _bannerAd!.load();
  }

  /// 전면 광고 로드
  Future<void> loadInterstitialAd({
    Function()? onLoaded,
    Function(LoadAdError)? onFailed,
  }) async {
    await InterstitialAd.load(
      adUnitId: AdConfig.interstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          onLoaded?.call();
          if (kDebugMode) {
            print('AdService: Interstitial ad loaded');
          }
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdLoaded = false;
          _interstitialAd = null;
          onFailed?.call(error);
          if (kDebugMode) {
            print('AdService: Interstitial ad failed to load: ${error.message}');
          }
        },
      ),
    );
  }

  /// 전면 광고 표시
  Future<void> showInterstitialAd({
    Function()? onAdDismissed,
    Function()? onAdFailed,
  }) async {
    if (!_isInterstitialAdLoaded || _interstitialAd == null) {
      onAdFailed?.call();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialAdLoaded = false;
        onAdDismissed?.call();
        // 다음 광고 미리 로드
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialAdLoaded = false;
        onAdFailed?.call();
        if (kDebugMode) {
          print('AdService: Interstitial ad failed to show: ${error.message}');
        }
        loadInterstitialAd();
      },
    );

    await _interstitialAd!.show();
  }

  /// 보상형 광고 로드
  Future<void> loadRewardedAd({
    Function()? onLoaded,
    Function(LoadAdError)? onFailed,
  }) async {
    await RewardedAd.load(
      adUnitId: AdConfig.rewardedAdId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoaded = true;
          onLoaded?.call();
          if (kDebugMode) {
            print('AdService: Rewarded ad loaded');
          }
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdLoaded = false;
          _rewardedAd = null;
          onFailed?.call(error);
          if (kDebugMode) {
            print('AdService: Rewarded ad failed to load: ${error.message}');
          }
        },
      ),
    );
  }

  /// 보상형 광고 표시
  Future<void> showRewardedAd({
    required Function(RewardItem reward) onRewarded,
    Function()? onAdDismissed,
    Function()? onAdFailed,
  }) async {
    if (!_isRewardedAdLoaded || _rewardedAd == null) {
      onAdFailed?.call();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _isRewardedAdLoaded = false;
        onAdDismissed?.call();
        // 다음 광고 미리 로드
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        _isRewardedAdLoaded = false;
        onAdFailed?.call();
        if (kDebugMode) {
          print('AdService: Rewarded ad failed to show: ${error.message}');
        }
        loadRewardedAd();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        onRewarded(reward);
        if (kDebugMode) {
          print('AdService: User earned reward: ${reward.amount} ${reward.type}');
        }
      },
    );
  }

  /// 배너 광고 해제
  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdLoaded = false;
  }

  /// 모든 광고 해제
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _bannerAd = null;
    _interstitialAd = null;
    _rewardedAd = null;
    _isBannerAdLoaded = false;
    _isInterstitialAdLoaded = false;
    _isRewardedAdLoaded = false;
  }
}
