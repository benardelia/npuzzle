import 'dart:developer' as developer show log;

import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:npuzzle/ads_helper.dart';
import 'package:npuzzle/state_management.dart/app_controller.dart';
import 'package:npuzzle/utils/logger.dart';

class AdsController extends GetxController {
  Rx<BannerAd>? bunnerAd;
  Rx<NativeAd>? nativeAd;
  Rx<InterstitialAd?>? interstitialAd;
  Rx<RewardedAd?>? rewardedAd;
  Rx<RewardedInterstitialAd>? rewardedInterstitialAd;

  int tries = 0;

  @override
  void onInit() {
    super.onInit();
    // Initialize ads
    loadBannerAd();
    loadRewardedAd();
    loadInterstitialAd();
  }

  @override
  void onClose() {
    bunnerAd?.value.dispose();
    nativeAd?.value.dispose();
    interstitialAd?.value?.dispose();
    rewardedAd?.value?.dispose();
    rewardedInterstitialAd?.value.dispose();

    super.onClose();
  }

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
                appController.resetPeriod();
                appController.countDown();
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
      // Reward the user for watching an ad.
      // var currentLevel = await appController.appBox.get('val');
      // appController.appBox.put('val', currentLevel + 1);
      // appController.countDown(callback)
      // nextLevel(widget.level);
      // setState(() {});
    }).then((value) {
      Log.w("In here now: AfterAdd");
      loadRewardedAd();
    });
  }

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

              appController.resetPeriod();

              if (Get.isDialogOpen == true) {
                Future.delayed((const Duration(milliseconds: 300)), () {
                  Get.back();
                  appController.countDown();
                });
              }
            },
          );

          interstitialAd?.value = ad;
        },
        onAdFailedToLoad: (err) {
          print('Failed to load an interstitial ad: ${err.message}');
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
}
