import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:npuzzle/colors.dart';
import 'package:npuzzle/inapp_purchase/inapp_purchase_util.dart';
import 'package:npuzzle/state_management.dart/app_controller.dart';
import 'package:npuzzle/utils/logger.dart';
import 'package:npuzzle/widgets/instruction.dart' show Instruction;
import 'package:url_launcher/url_launcher.dart';

class SideNavigator extends StatelessWidget {
  const SideNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppController>();
    final inAppPurchaseUtil = Get.find<InAppPurchaseUtil>();
    return Drawer(
      width: Get.width * 0.7,
      child: Column(
        children: [
          Image.asset('assets/8puzzle.png'),
          TextButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              showDialog(
                  context: context,
                  builder: (context) {
                    return const Instruction();
                  });
            },
            icon: const Icon(Icons.tips_and_updates_outlined),
            label: const Text('Goal State'),
          ),
          TextButton.icon(
            onPressed: inAppPurchaseUtil.isSubscribed.value
                ? null
                : () async {
                    inAppPurchaseUtil.isSubscribed;
                    Navigator.pop(context);
                    Get.back();
                    inAppPurchaseUtil.buyNonConsumable('8_puzzle_subscription');
                  },
            icon: const Icon(Icons.lock_open),
            label: Obx(() {
              return Text(inAppPurchaseUtil.isSubscribed.value
                  ? 'Levels Unlocked'
                  : 'Unlock Levels');
            }),
          ),
          TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                    context: context,
                    builder: (context) =>
                        const PickColors()).then((value) =>
                    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                        systemNavigationBarColor: controller.appColor.value)));
              },
              icon: const Icon(Icons.color_lens),
              label: const Text('Change Color')),
          TextButton.icon(
            onPressed: () async {
              final Uri url = Uri.parse(
                  'https://play.google.com/store/apps/details?id=com.bravetech.npuzzle');
              if (!await launchUrl(url)) {
                throw Exception('Could not launch $url');
              }
            },
            icon: const Icon(Icons.star_rate_rounded),
            label: const Text('Rate Us'),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.light_mode_outlined),
              Obx(() {
                return Switch(
                    value: controller.isDarkTheme.value,
                    onChanged: (value) {
                      Log.i('Theme changed to ${value ? 'Dark' : 'Light'}');
                      controller.isDarkTheme.value =
                          !(controller.isDarkTheme.value);
                      controller.appBox
                          .put('isDarkTheme', controller.isDarkTheme.value);
                    });
              })
            ],
          )
        ],
      ),
    );
  }
}
