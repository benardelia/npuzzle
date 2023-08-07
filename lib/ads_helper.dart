import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9035859643875042/4048900223';
    } else if (Platform.isIOS) {
      // to be implemented
      return '';
    }
    throw UnsupportedError("Unsupported platform");
  }

  static String get nativeAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/2247696110';
    } else if (Platform.isIOS) {
      // to be implemented
      return '';
    }
    throw UnsupportedError("Unsupported platform");
  }

  static String get openAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9035859643875042/2193873010';
    } else if (Platform.isIOS) {
      // to be implemented
      return '';
    }
    throw UnsupportedError("Unsupported platform");
  }


   static String get rewardAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9035859643875042/2311633951';
    } else if (Platform.isIOS) {
      // to be implemented
      return '';
    }
    throw UnsupportedError("Unsupported platform");
  }
}
