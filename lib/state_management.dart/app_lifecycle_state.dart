import 'package:get/get.dart';
import 'package:flutter/widgets.dart';
import 'package:npuzzle/state_management.dart/ads_controller.dart';
import 'package:npuzzle/state_management.dart/app_controller.dart';
import 'package:npuzzle/utils/logger.dart';

class AppLifecycleController extends GetxController
    with WidgetsBindingObserver {
  final lifecycleState = Rx<AppLifecycleState?>(null);

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    lifecycleState.value = state;

    AdsController adsController = Get.find();
    AppController appController = Get.find();

    // Handle your logic here
    switch (state) {
      case AppLifecycleState.resumed:
        Log.i("✅ App resumed");
        if (adsController.appOpenCount > 5) {
          // this delay ensure if the game is in play ground should atleast pass one second for the the bottom code to work correct
          await Future.delayed(const Duration(milliseconds: 1600));
          adsController.showAppOpenAd();
        } else {
          adsController.appOpenCount.value++;
        }

        // this ensure time resume coutdown only if game become inactive when countdown was active
        // to prevent app countdown to start in any part of the app even user leave the app before starting playing game
        // it checks if the timer is inactive and the timer is atleast less that
        if (appController.timer?.isActive == false &&
            appController.gamePeriod.value < AppController.defaultPeriod) {
          appController.countDown();
        }
        break;
      case AppLifecycleState.inactive:
        Log.i("⏸️ App inactive");
        if (appController.timer?.isActive == true) {
          appController.timer!.cancel();
        }
        break;
      case AppLifecycleState.paused:
        Log.i("🚫 App paused");
        break;
      case AppLifecycleState.detached:
        Log.i("🛑 App detached");
        break;
      case AppLifecycleState.hidden:
        Log.i("📵 App detached");
        break;
    }
  }
}
