import 'dart:io';
import 'package:flutter/foundation.dart'; // For kDebugMode

class AdHelper {
  static String get bannerAdUnitId {
    if (kDebugMode) {
      return AdHelperTest.bannerAdUnitId;
    }

    if (Platform.isAndroid) {
      return 'ca-app-pub-9035859643875042/4048900223';
    } else if (Platform.isIOS) {
      // to be implemented
      return '';
    }
    throw UnsupportedError("Unsupported platform");
  }

  static String get nativeAdUnitId {
    if (kDebugMode) {
      return AdHelperTest.nativeAdUnitId;
    }

    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/2247696110';
    } else if (Platform.isIOS) {
      // to be implemented
      return '';
    }
    throw UnsupportedError("Unsupported platform");
  }

  static String get openAdUnitId {
    if (kDebugMode) {
      return AdHelperTest.openAdUnitId;
    }

    if (Platform.isAndroid) {
      return 'ca-app-pub-9035859643875042/2193873010';
    } else if (Platform.isIOS) {
      // to be implemented
      return '';
    }
    throw UnsupportedError("Unsupported platform");
  }

  static String get rewardAdUnitId {
    if (kDebugMode) {
      return AdHelperTest.rewardAdUnitId;
    }

    if (Platform.isAndroid) {
      return 'ca-app-pub-9035859643875042/2311633951';
    } else if (Platform.isIOS) {
      // to be implemented
      return '';
    }
    throw UnsupportedError("Unsupported platform");
  }

  static String get interstitialAdUnitId {
    if (kDebugMode) {
      return AdHelperTest.interstitialAdUnitId;
    }

    if (Platform.isAndroid) {
      // TODO: replace with your actual interstitial ad unit ID
      return '';
    } else if (Platform.isIOS) {
      // to be implemented
      return '';
    }
    throw UnsupportedError("Unsupported platform");
  }
}

// Ad helper for test ad
class AdHelperTest {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get nativeAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/2247696110';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2247696110';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get openAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get rewardAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3940256099942544/1033173712";
    } else if (Platform.isIOS) {
      return "ca-app-pub-3940256099942544/4411468910";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }
}
