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
      width: Get.width * 0.75,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              controller.appColor.value.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      controller.appColor.value,
                      controller.appColor.value.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/8puzzle.png',
                        width: 80,
                        height: 80,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '8-Puzzle Game',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'sketch3d',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(() {
                      final level = controller.currentLevel.value + 1;
                      return Text(
                        'Level $level',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // Menu Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  children: [
                    _buildMenuItem(
                      context: context,
                      icon: Icons.tips_and_updates_outlined,
                      title: 'Goal State',
                      subtitle: 'View target configuration',
                      onTap: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (context) => const Instruction(),
                        );
                      },
                    ),

                    Obx(() {
                      final isSubscribed = inAppPurchaseUtil.isSubscribed.value;
                      return _buildMenuItem(
                        context: context,
                        icon: isSubscribed ? Icons.lock_open : Icons.lock,
                        title: isSubscribed ? 'Levels Unlocked' : 'Unlock Levels',
                        subtitle: isSubscribed
                            ? 'All levels available'
                            : 'Get access to all levels',
                        onTap: isSubscribed
                            ? null
                            : () {
                                Navigator.pop(context);
                                inAppPurchaseUtil.buyNonConsumable('8_puzzle_subscription');
                              },
                        trailing: isSubscribed
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : null,
                      );
                    }),

                    _buildMenuItem(
                      context: context,
                      icon: Icons.color_lens,
                      title: 'Change Theme',
                      subtitle: 'Customize app colors',
                      onTap: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (context) => const PickColors(),
                        ).then((value) => SystemChrome.setSystemUIOverlayStyle(
                          SystemUiOverlayStyle(
                            systemNavigationBarColor: controller.appColor.value,
                          ),
                        ));
                      },
                    ),

                    _buildMenuItem(
                      context: context,
                      icon: Icons.star_rate_rounded,
                      title: 'Rate Us',
                      subtitle: 'Share your feedback',
                      onTap: () async {
                        final Uri url = Uri.parse(
                          'https://play.google.com/store/apps/details?id=com.bravetechteam.npuzzle',
                        );
                        if (!await launchUrl(url)) {
                          throw Exception('Could not launch $url');
                        }
                      },
                    ),

                    const Divider(height: 32, indent: 16, endIndent: 16),

                    // Theme Toggle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: controller.appColor.value.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.light_mode_outlined,
                                color: controller.appColor.value,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dark Mode',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  Text(
                                    'Toggle theme',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Obx(() {
                              return Switch(
                                value: controller.isDarkTheme.value,
                                onChanged: (value) {
                                  Log.i('Theme changed to ${value ? 'Dark' : 'Light'}');
                                  controller.isDarkTheme.value = value;
                                  controller.appBox.put('isDarkTheme', value);
                                },
                                activeColor: controller.appColor.value,
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '© 2024 BraveTech Team',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    final controller = Get.find<AppController>();
    final isDisabled = onTap == null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDisabled
                  ? Colors.grey.shade100
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isDisabled
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: isDisabled
                        ? LinearGradient(
                            colors: [
                              Colors.grey.shade300,
                              Colors.grey.shade400,
                            ],
                          )
                        : LinearGradient(
                            colors: [
                              controller.appColor.value.withOpacity(0.2),
                              controller.appColor.value.withOpacity(0.1),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: isDisabled
                        ? Colors.grey.shade600
                        : controller.appColor.value,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDisabled
                              ? Colors.grey.shade600
                              : Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null)
                  trailing
                else if (!isDisabled)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}