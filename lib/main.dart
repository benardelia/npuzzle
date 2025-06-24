import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:npuzzle/levels.dart';
import 'package:npuzzle/state_management.dart/app_controller.dart';
import 'package:npuzzle/state_management.dart/controller_registry.dart';
import 'package:npuzzle/utils/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  unawaited(MobileAds.instance.initialize());

  await Hive.initFlutter();
  var box = await Hive.openBox('Level');

  if (box.isEmpty) {
    await box.put('val', 0);
    await box.put('color', const Color(0xffa5773b).value);
  }

  registerControllers();

  runApp(const PlayGroung());
}

class PlayGroung extends StatefulWidget {
  const PlayGroung({super.key});

  @override
  State<PlayGroung> createState() => _PlayGroungState();
}

class _PlayGroungState extends State<PlayGroung> {
  AppController appController = Get.find<AppController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return GetMaterialApp(
        theme: ThemeData(
            useMaterial3: true,
            brightness: appController.isDarkTheme.value
                ? Brightness.dark
                : Brightness.light,
            textTheme: textTheme),
        debugShowCheckedModeBanner: false,
        home: const Levels(),
        // initialBinding: BindingsBuilder(
        //   () {
        //     Get.put<InAppPurchaseUtil>(inappPurchaseUtil);
        //   },
        // ),
      );
    });
  }
}
