import 'package:get/get.dart';
import 'package:npuzzle/inapp_purchase/inapp_purchase_util.dart';
import 'package:npuzzle/state_management.dart/ads_controller.dart';
import 'package:npuzzle/state_management.dart/app_controller.dart';

void registerControllers() {
  // Registering the InappPurchaseUtil controller
  // Get.put(InappPurchaseUtil.instance, permanent: true);

  // // Registering the Levels controller
  // Get.put(LevelsController(), permanent: true);

  // // Registering the AdsController
  // Get.put(AdsController(), permanent: true);
  // Registering the AdsController
  Get.put(AppController(), permanent: true);
  Get.put(AdsController(), permanent: true);
  Get.put(InAppPurchaseUtil(), permanent: true);
}
