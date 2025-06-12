import 'dart:ui';

import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:hive_flutter/adapters.dart';

class AppController extends GetxController {
  RxBool isDarkTheme = false.obs;

  Rx<Color> appColor = const Color.fromARGB(255, 233, 210, 76).obs; // add this

  @override
  void onInit() {
    var level = Hive.box('level');
    appColor.value = Color(level.get('color'));
    super.onInit();
  }
}
