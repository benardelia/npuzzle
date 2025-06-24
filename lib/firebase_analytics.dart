import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseAnalyticsService {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  static logSubscription() {
    analytics.logPurchase();
  }

  static logLevelUp({
    required int level,
    String? character,
    Map<String, Object>? parameters,
    AnalyticsCallOptions? callOptions,
  }) {
    analytics.logLevelUp(level: level);
  }

  static logAdImpression({
    String? adPlatform,
    String? adSource,
    String? adFormat,
    String? adUnitName,
    double? value,
    String? currency,
    Map<String, Object>? parameters,
    AnalyticsCallOptions? callOptions,
  }) {
    analytics.logAdImpression(
        adFormat: adFormat,
        adPlatform: adPlatform,
        adSource: adSource,
        adUnitName: adUnitName,
        value: value,
        currency: currency,
        parameters: parameters,
        callOptions: callOptions);
  }
}
