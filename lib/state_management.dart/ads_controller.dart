import 'dart:developer' as developer show log;

import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:npuzzle/ads_helper.dart';
import 'package:npuzzle/firebase_analytics.dart';
import 'package:npuzzle/state_management.dart/app_controller.dart';
import 'package:npuzzle/utils/logger.dart';

class AdsController extends GetxController {
  Rx<BannerAd>? bunnerAd;
  Rx<NativeAd>? nativeAd;
  Rx<InterstitialAd?>? interstitialAd;
  Rx<RewardedAd?>? rewardedAd;
  Rx<RewardedInterstitialAd>? rewardedInterstitialAd;
  Rx<AppOpenAd?>? appOpenAd;
  RxInt appOpenCount = 0.obs;

  int tries = 0;

  @override
  void onInit() {
    super.onInit();
    // Initialize ads
    loadBannerAd();
    loadRewardedAd();
    loadInterstitialAd();
    loadAppOpenAd();
    listenToAppStateChanges();
  }

  @override
  void onClose() {
    bunnerAd?.value.dispose();
    nativeAd?.value.dispose();
    interstitialAd?.value?.dispose();
    rewardedAd?.value?.dispose();
    rewardedInterstitialAd?.value.dispose();
    appOpenAd?.value?.dispose();

    super.onClose();
  }

  // --------------------------------  Banner Ad ------------------------------------------

  loadBannerAd() {
    if (bunnerAd?.value != null) {
      bunnerAd?.value.dispose();
    }

    Log.i('Trying to load banner ad');
    bunnerAd = Rx(BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          Log.i('Banner ad loaded successfully');
          bunnerAd?.value = ad as BannerAd;
        },
        onAdFailedToLoad: (ad, error) {
          // Releases an ad resource when it fails to load
          ad.dispose();
          Log.e(
              'Banner ad fail to load (code=${error.code} message=${error.message})');
          // print('Ad load failed (code=${error.code} message=${error.message})');
        },
      ),
    ));

    bunnerAd!.value.load();
  }

  // --------------------------------  Rewarded Ad ------------------------------------------

  void loadRewardedAd() {
    rewardedAd = Rx<RewardedAd?>(null);

    // rewarded ad implemented here
    RewardedAd.load(
      adUnitId: AdHelper.rewardAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
              // Called when the ad showed the full screen content.
              onAdShowedFullScreenContent: (ad) {
                Log.i('Rewarded ad showed full screen content');
              },
              // Called when an impression occurs on the ad.
              onAdImpression: (ad) {
                Log.i('Rewarded ad impression recorded');
                FirebaseAnalyticsService.logAdImpression(
                    adFormat: 'Rewarded Ad',
                    adPlatform: 'AdMob',
                    adUnitName: ad.adUnitId,
                    adSource: 'Admob');
              },
              // Called when the ad failed to show full screen content.
              onAdFailedToShowFullScreenContent: (ad, err) {
                // Dispose the ad here to free resources.
                ad.dispose();
                Get.snackbar(
                  'Ad Error',
                  'Ad failed to show: ${err.message}',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              // Called when the ad dismissed full screen content.
              onAdDismissedFullScreenContent: (ad) async {
                AppController appController = Get.find();
                // var currentLevel = await appController.appBox.get('val');
                // Get.snackbar('One level Unlocked',
                //     'You can now play level ${currentLevel + 1}',
                //     snackPosition: SnackPosition.BOTTOM,
                //     duration: const Duration(seconds: 4));

                appController.resetPeriod(discount: 1);
                await Future.delayed(const Duration(seconds: 1));
                appController.countDown();
                if (Get.isDialogOpen == true) {
                  Get.back();
                }
                // Dispose the ad here to free resources.

                ad.dispose();
              },
              // Called when a click is recorded for an ad.
              onAdClicked: (ad) {});
          // debugPrint('$ad loaded.');
          // Keep a reference to the ad so you can show it later.
          Log.i('Rewarded ad loadedd successfully');
          rewardedAd?.value = ad;
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (LoadAdError error) {
          // debugPrint('RewardedAd failed to load: $error');
          Log.i('Rewarded ad is null, trying to load again $error');
          developer.log(
            'Rewarded ad failed to load: ${error.code} - ${error.message}',
            name: 'AdsController',
          );
        },
      ),
    );
  }

  showRewardedAd() {
    if (rewardedAd?.value == null) {
      Log.i('Rewarded ad is null, trying to load again');
      Get.snackbar(
          'Unlocked level', 'Rewarded ad failed to load, trying again...',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2));
      loadRewardedAd();
      return;
    }

    rewardedAd!.value!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) async {
      Log.i('User earn reward');
    }).then((value) {
      Log.w("In here now: AfterAdd");
      AppController appController = Get.find();
      appController.timer?.cancel();
      loadRewardedAd();
    });
  }

  // --------------------------------  Interstitial Ad ------------------------------------------

  void loadInterstitialAd() {
    interstitialAd = Rx<InterstitialAd?>(null);
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              // TODO: navigate to the next level
              AppController appController = Get.find();

              appController.resetPeriod(discount: 1);

              if (Get.isDialogOpen == true) {
                Future.delayed((const Duration(milliseconds: 300)), () {
                  Get.back();
                  appController.countDown();
                });
              }
            },
            onAdImpression: (ad) {
              FirebaseAnalyticsService.logAdImpression(
                  adFormat: 'Interstitial Ad',
                  adPlatform: 'AdMob',
                  adUnitName: ad.adUnitId,
                  adSource: 'Admob');
            },
          );

          interstitialAd?.value = ad;
        },
        onAdFailedToLoad: (err) {
          Log.e('Failed to load an interstitial ad: ${err.message}');
        },
      ),
    );
  }

  showInterstitialAd() {
    if (interstitialAd?.value == null) {
      Log.i('InterstitialAd ad is null, trying to load again');
      Get.snackbar(
          'Unlocked level', 'InterstitialAd ad failed to load, trying again...',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2));
      loadInterstitialAd();
      return;
    }

    interstitialAd!.value!.show().then((value) {
      loadInterstitialAd();
    });
  }

  // --------------------------------  App Open Ad ------------------------------------------

  bool _isShowingAd = false;

  void listenToAppStateChanges() {
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream.forEach((state) {
      Log.i(state.name);
      _onAppStateChanged(state);
    });
  }

  void _onAppStateChanged(AppState appState) {
    // Try to show an app open ad if the app is being resumed and
    // we're not already showing an app open ad.
    if (appState == AppState.foreground) {
      showAppOpenAd();
    }
  }

  void loadAppOpenAd() {
    appOpenAd = Rx<AppOpenAd?>(null);
    AppOpenAd.load(
      adUnitId: AdHelper.appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          Log.e('*****************AppOpenAd loaded successful');
          appOpenAd!.value = ad;
        },
        onAdFailedToLoad: (error) {
          Log.e('AppOpenAd failed to load: $error');
          // Handle the error.
        },
      ),
    );
  }

  void showAppOpenAd() {
    if (appOpenAd?.value == null) {
      Log.w('Tried to show ad before available.');
      loadAppOpenAd();
      return;
    }
    if (_isShowingAd) {
      Log.w('Tried to show ad while already showing an ad.');
      return;
    }

    Log.i('Showing App Open Ads');
    // Set the fullScreenContentCallback and show the ad.
    appOpenAd!.value!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        appOpenCount.value = 0;
        _isShowingAd = true;
        Log.i('$ad onAdShowedFullScreenContent');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        Log.e('$ad onAdFailedToShowFullScreenContent: $error');
        _isShowingAd = false;
        ad.dispose();
        appOpenAd!.value = null;
      },
      onAdDismissedFullScreenContent: (ad) {
        Log.i('$ad onAdDismissedFullScreenContent');
        _isShowingAd = false;
        ad.dispose();
        appOpenAd!.value = null;
        loadAppOpenAd();
      },
      onAdImpression: (ad) {
        FirebaseAnalyticsService.logAdImpression(
            adFormat: 'App Open Ad',
            adPlatform: 'AdMob',
            adUnitName: ad.adUnitId,
            adSource: 'Admob');
      },
    );

    appOpenAd!.value!.show();
  }
}
