class AdConfig {
  // 테스트 모드 강제 활성화 (true = 항상 테스트 광고 사용)
  static const bool forceTestMode = true;

  // 테스트 App ID (AndroidManifest.xml과 일치해야 함)
  static const String testAppId = 'ca-app-pub-3940256099454444~3347511713';

  // 테스트 광고 ID - Google 공식 테스트 ID
  static const String testBannerAdId = 'ca-app-pub-3940256099454444/6300978111';
  static const String testInterstitialAdId = 'ca-app-pub-3940256099454444/1033173712';
  static const String testRewardedAdId = 'ca-app-pub-3940256099454444/5224354917';

  // 실제 광고 ID (프로덕션용 - 나중에 사용)
  static const String _prodBannerAdId = 'ca-app-pub-5534374692236631/4938466405';
  static const String _prodInterstitialAdId = 'ca-app-pub-5534374692236631/1661566372';
  static const String _prodRewardedAdId = 'ca-app-pub-5534374692236631/8695530973';

  // 테스트 디바이스 ID 목록
  static const List<String> testDeviceIds = [
    'AF2B9423F9F7304984544E52796CD86D', // 실제 테스트 기기
  ];

  // 현재 사용할 광고 ID 반환
  static String get bannerAdId =>
      forceTestMode ? testBannerAdId : _prodBannerAdId;

  static String get interstitialAdId =>
      forceTestMode ? testInterstitialAdId : _prodInterstitialAdId;

  static String get rewardedAdId =>
      forceTestMode ? testRewardedAdId : _prodRewardedAdId;

  static bool get isTestMode => forceTestMode;
}
