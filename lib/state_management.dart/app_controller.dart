import 'dart:async';
import 'dart:ui';

import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:hive_flutter/adapters.dart';

class AppController extends GetxController {
  RxBool isDarkTheme = false.obs;

  Rx<Color> appColor = const Color.fromARGB(255, 233, 210, 76).obs; // add this
  late Box appBox;

  RxInt currentLevel = 0.obs;

  @override
  void onInit() {
    appBox = Hive.box('level');
    appColor.value = Color(appBox.get('color'));
    isDarkTheme.value = appBox.get('isDarkTheme', defaultValue: false);
    currentLevel.value = appBox.get('val', defaultValue: 0);
    super.onInit();
  }

  RxInt gamePeriod = 100.obs;

  Timer? timer;

  countDown(Function() callback) {
    timer = Timer.periodic(const Duration(seconds: 1), (counts) async {
      gamePeriod.value--;
      if (gamePeriod.value < 1) {
        await callback();
        gamePeriod.value = 100;
      }
    });
  }
}
