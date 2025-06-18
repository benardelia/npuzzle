import 'dart:async';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:npuzzle/state_management.dart/ads_controller.dart';
import 'package:npuzzle/utils/logger.dart';
import 'package:npuzzle/widgets/game_over_alert.dart';

class AppController extends GetxController {
  RxBool isDarkTheme = false.obs;

  Rx<Color> appColor = const Color(0xffece1cd).obs; // add this
  late Box appBox;

  RxInt currentLevel = 0.obs;

  RxBool restart = false.obs;

  @override
  void onInit() {
    appBox = Hive.box('level');
    appColor.value = Color(appBox.get('color', defaultValue: 0xffece1cd));
    isDarkTheme.value = appBox.get('isDarkTheme', defaultValue: false);
    currentLevel.value = appBox.get('val', defaultValue: 0);
    super.onInit();
  }

  static int defaultPeriod = 30;

  RxInt gamePeriod = defaultPeriod.obs;

  resetPeriod({int? discount}) {
    gamePeriod.value = defaultPeriod - (discount ?? 0);
  }

  Timer? timer;

  countDown() {
    try {
      timer?.cancel();
      // Log.w('Game period: ${gamePeriod.value}');
      timer = null;

      timer = Timer.periodic(const Duration(seconds: 1), (counts) async {
        gamePeriod.value--;
        // Log.i('Game period: ${gamePeriod.value}');
        if (gamePeriod.value < 1) {
          timer?.cancel();
          Get.dialog(
            GameOverAlert(
              title: 'Time Up!',
              message: '😎😌',
              onNegativeAction: () async {
                Get.back();
                resetPeriod();
                countDown();
                restart.value = true;
                // nextLevel(widget.level - 1);
              },
              onPositiveAction: () async {
                await Get.find<AdsController>().showRewardedAd();
                Get.back();
                resetPeriod();
              },
              negativeActionText: 'Restart',
              positiveActionText: 'Add Time',
            ),
            barrierDismissible: false,
          );
        }
      });
    } catch (e) {
      Log.e('Error in countDown: $e');
    }
  }
}
