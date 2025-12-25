import 'package:flutter/foundation.dart';

class AdConfig {
  // 실제 광고 ID (프로덕션용)
  static const String _prodBannerAdId = 'ca-app-pub-5534374692236631/4938466405';
  static const String _prodInterstitialAdId = 'ca-app-pub-5534374692236631/1661566372';
  static const String _prodRewardedAdId = 'ca-app-pub-5534374692236631/8695530973';

  // 테스트 광고 ID (디버그용)
  static const String _testBannerAdId = 'ca-app-pub-3940256069945444/6300978111';
  static const String _testInterstitialAdId = 'ca-app-pub-3940256069945444/1033173712';
  static const String _testRewardedAdId = 'ca-app-pub-3940256069945444/5224354917';

  // 테스트 디바이스 ID 목록
  // Logcat에서 "Use RequestConfiguration.Builder.setTestDeviceIds..." 메시지를 확인하여 추가
  static const List<String> testDeviceIds = [
    'AF2B9423F9F7304984544E52796CD86D', // SM S721N
  ];

  // 디버그 모드에 따라 적절한 광고 ID 반환
  static String get bannerAdId =>
      kDebugMode ? _testBannerAdId : _prodBannerAdId;

  static String get interstitialAdId =>
      kDebugMode ? _testInterstitialAdId : _prodInterstitialAdId;

  static String get rewardedAdId =>
      kDebugMode ? _testRewardedAdId : _prodRewardedAdId;
}
