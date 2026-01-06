import 'dart:async';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:npuzzle/state_management.dart/ads_controller.dart';
import 'package:npuzzle/utils/logger.dart';
import 'package:npuzzle/widgets/game_over_alert.dart';

class AppController extends GetxController {
  RxBool isDarkTheme = false.obs;
  Rx<Color> appColor = const Color(0xffece1cd).obs;
  late Box appBox;
  RxInt currentLevel = 0.obs;
  RxBool restart = false.obs;

  // Track if dialog is currently showing to prevent multiple dialogs
  bool _isDialogShowing = false;

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

  void resetPeriod({int? discount}) {
    gamePeriod.value = defaultPeriod - (discount ?? 0);
  }

  Timer? timer;

  void countDown() {
    try {
      // CRITICAL: Cancel any existing timer first
      timer?.cancel();
      timer = null;

      // Reset dialog flag when starting new countdown
      _isDialogShowing = false;

      timer = Timer.periodic(const Duration(seconds: 1), (counts) async {
        gamePeriod.value--;
        // Log.i('Game period: ${gamePeriod.value}');

        // CRITICAL: Check if time is up AND dialog is not already showing
        if (gamePeriod.value < 1 && !_isDialogShowing) {
          // Cancel timer BEFORE showing dialog
          timer?.cancel();
          timer = null;

          // Set flag to prevent multiple dialogs
          _isDialogShowing = true;

          // Show dialog
          _showTimeUpDialog();
        }
      });
    } catch (e) {
      Log.e('Error in countDown: $e');
    }
  }

  void _showTimeUpDialog() {
    Get.dialog(
      GameOverAlert(
        title: 'Time Up!',
        message: '😎😌',
        onNegativeAction: () => _handleRestart(),
        onPositiveAction: () => _handleAddTime(),
        negativeActionText: 'Restart',
        positiveActionText: 'Add Time',
      ),
      barrierDismissible: false,
    );
  }

  // FIXED: Separate method for restart action
  void _handleRestart() {
    Log.d('Restart button pressed');

    // Close the dialog first
    try {
      if (Get.isDialogOpen == true) {
        Log.d('trying pop unopened diolog');
        Future.delayed(const Duration(milliseconds: 300), () {
          Get.back();
        });
        
      } else {
        Log.d('Cant pop unopened diolog');
      }
    } catch (e) {
      // Ignore
      Log.e('Error closing dialog: $e');
    }

    // Small delay to ensure dialog is fully closed
    Future.delayed(const Duration(milliseconds: 100), () {
      // Reset the flag
      _isDialogShowing = false;

      // Reset game state
      resetPeriod(discount: 1);

      // Trigger restart
      restart.value = true;

      // Restart countdown
      countDown();
    });
  }

  // FIXED: Separate method for add time action
  void _handleAddTime() {
    Log.d('Add Time button pressed');

    // Close the dialog first
    if (Get.isDialogOpen == true) {
      Future.delayed(const Duration(milliseconds: 100), () {
          Get.back();
        });
    }

    // Small delay to ensure dialog is fully closed
    Future.delayed(const Duration(milliseconds: 150), () {
      // Reset the flag
      _isDialogShowing = false;

      // Show rewarded ad
      Get.find<AdsController>().showRewardedAd();

      // Reset period and restart countdown
      // CRITICAL BUG FIX: You were missing countDown() here!
      resetPeriod(discount: 1);
      countDown(); // ← This was missing!
    });
  }

  // ALTERNATIVE: If you want to handle the ad callback properly
  void _handleAddTimeWithCallback() {
    Log.d('Add Time button pressed');

    // Close the dialog first
    if (Get.isDialogOpen == true) {
      Get.back();
    }

    // Small delay to ensure dialog is fully closed
    Future.delayed(const Duration(milliseconds: 100), () async {
      // Reset the flag
      _isDialogShowing = false;

      try {
        // Show rewarded ad and wait for result
        await Get.find<AdsController>().showRewardedAd();

        // Only reset and restart if ad was successfully shown
        resetPeriod(discount: 1);
        countDown();
      } catch (e) {
        Log.e('Error showing rewarded ad: $e');

        // If ad fails, still restart the countdown
        resetPeriod(discount: 1);
        countDown();
      }
    });
  }

  // Method to add time from reward ad
  void addTimeFromReward({int seconds = 30}) {
    Log.d('Adding $seconds seconds from reward');

    // Add time to current period
    gamePeriod.value += seconds;

    // If timer is not running, start it
    if (timer == null || !timer!.isActive) {
      countDown();
    }
  }

  // Clean up when controller is disposed
  @override
  void onClose() {
    timer?.cancel();
    timer = null;
    super.onClose();
  }

  // Method to stop timer (call this when navigating away from game)
  void stopTimer() {
    timer?.cancel();
    timer = null;
    _isDialogShowing = false;
  }

  // Method to pause timer
  void pauseTimer() {
    timer?.cancel();
    timer = null;
  }

  // Method to resume timer
  void resumeTimer() {
    if (gamePeriod.value > 0 && (timer == null || !timer!.isActive)) {
      countDown();
    }
  }
}
