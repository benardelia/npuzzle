import 'package:get/get.dart';
import 'package:flutter/widgets.dart';
import 'package:npuzzle/state_management.dart/ads_controller.dart';
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    lifecycleState.value = state;

    AdsController adsController = Get.find();

    // Handle your logic here
    switch (state) {
      case AppLifecycleState.resumed:
        Log.i("✅ App resumed");
        if (adsController.appOpenCount > 5) {
          adsController.showAppOpenAd();
        } else {
          adsController.appOpenCount.value++;
        }
        break;
      case AppLifecycleState.inactive:
        Log.i("⏸️ App inactive");
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
