import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:npuzzle/ads_helper.dart';
import 'package:npuzzle/calculations.dart';
import 'package:npuzzle/ground.dart';
import 'package:npuzzle/inapp_purchase/inapp_purchase_util.dart';
import 'package:npuzzle/state_management.dart/app_controller.dart';
import 'package:npuzzle/utils/logger.dart';
import 'package:npuzzle/widgets/drawer.dart';
import 'package:npuzzle/widgets/game_over_alert.dart';
import 'package:npuzzle/widgets/instruction.dart';

class Levels extends StatefulWidget {
  const Levels({super.key});

  static late List<Offset> winposition;
  static List levels = [
    [0, 1, 2, 3, 4, 5, 6, 8, 7],
    [0, 1, 2, 3, 4, 5, 8, 6, 7],
    [0, 1, 2, 8, 4, 5, 3, 6, 7],
    [0, 1, 2, 4, 8, 5, 3, 6, 7],
    [0, 1, 2, 4, 5, 8, 3, 6, 7],
    [0, 1, 2, 4, 5, 7, 3, 6, 8],
   [0, 1, 2, 4, 5, 7, 3, 8, 6], 
    [0, 1, 2, 4, 5, 7, 8, 3, 6],
    [0, 1, 2, 8, 5, 7, 4, 3, 6],
    [0, 1, 2, 5, 8, 7, 4, 3, 6],
    [0, 8, 2, 5, 1, 7, 4, 3, 6],
    [8, 0, 2, 5, 1, 7, 4, 3, 6],
    [5, 0, 2, 8, 1, 7, 4, 3, 6],
    [5, 0, 2, 1, 8, 7, 4, 3, 6],
    [5, 8, 2, 1, 0, 7, 4, 3, 6],
    [5, 2, 8, 1, 0, 7, 4, 3, 6],
    [5, 2, 7, 1, 0, 8, 4, 3, 6],
    [5, 2, 7, 1, 8, 0, 4, 3, 6],
    [5, 2, 7, 1, 3, 0, 4, 8, 6],
    [5, 2, 7, 1, 3, 0, 8, 4, 6],
    [5, 2, 7, 8, 3, 0, 1, 4, 6],
    [8, 2, 7, 5, 3, 0, 1, 4, 6],
    [2, 8, 7, 5, 3, 0, 1, 4, 6],
    [2, 3, 7, 5, 8, 0, 1, 4, 6],
    [2, 3, 7, 5, 0, 8, 1, 4, 6],
    [2, 3, 8, 5, 0, 7, 1, 4, 6]
  ];

  @override
  State<Levels> createState() => _LevelsState();
}

class _LevelsState extends State<Levels> with SingleTickerProviderStateMixin {
  var controller = Get.find<AppController>();
  BannerAd? _ad;
  RewardedAd? _rewardedAd;
  int tries = 0;
  late AnimationController _animationController;

  void loadRewardedAd() {
    if (_rewardedAd != null) return; // Prevent multiple loads

    RewardedAd.load(
      adUnitId: AdHelper.rewardAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {},
            onAdImpression: (ad) {},
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ad failed to load'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedAd = null;
            },
            onAdClicked: (ad) {},
          );

          debugPrint('$ad loaded.');
          _rewardedAd = ad;
          tries = 0;

          // Show ad immediately after loading
          _rewardedAd!.show(
            onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
              var currentLevel = controller.appBox.get('val');
              controller.appBox.put('val', currentLevel + 1);
              if (mounted) {
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🎉 One level unlocked!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('RewardedAd failed to load: $error');
          tries++;
          if (tries < 3 && mounted) {
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) loadRewardedAd();
            });
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Unable to load ad. Please try again later.'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _ad?.dispose();
    _rewardedAd?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: controller.appColor.value,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    List<Offset> position = _generatePositions(size);
    Offset comparizon1 = position[8] - position[7];
    Offset comparizon2 = position[8] - position[5];
    Levels.winposition = position;

    final inAppPurchaseUtil = Get.find<InAppPurchaseUtil>();

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton(
        backgroundColor: controller.appColor.value.withOpacity(0.9),
        elevation: 4,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const Instruction(),
          );
        },
        child: const Icon(Icons.info_outline, size: 28),
      ),
      appBar: AppBar(
        title: const Text(
          '8-Puzzle',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            fontFamily: 'sketch3d',
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: controller.appColor.value,
        scrolledUnderElevation: 5,
        elevation: 0,
        centerTitle: true,
      ),
      drawer: const SideNavigator(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              controller.appColor.value.withOpacity(0.1),
              Colors.white,
              controller.appColor.value.withOpacity(0.05),
            ],
          ),
        ),
        child: Obx(() {
          controller.currentLevel.value;
          final currentLevel = controller.appBox.get('val') ?? 0;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: 100, // Support up to 100 levels
              itemBuilder: (context, index) {
                final isUnlocked = currentLevel >= index;
                final isCurrentLevel = currentLevel == index;

                return _buildLevelCard(
                  context,
                  index,
                  isUnlocked,
                  isCurrentLevel,
                  position,
                  comparizon1,
                  comparizon2,
                  currentLevel,
                  inAppPurchaseUtil,
                );
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLevelCard(
    BuildContext context,
    int index,
    bool isUnlocked,
    bool isCurrentLevel,
    List<Offset> position,
    Offset comparizon1,
    Offset comparizon2,
    int highLevel,
    InAppPurchaseUtil inAppPurchaseUtil,
  ) {
    return Hero(
      tag: 'level_$index',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleLevelTap(
            context,
            index,
            isUnlocked,
            position,
            comparizon1,
            comparizon2,
            highLevel,
            inAppPurchaseUtil,
          ),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isUnlocked
                    ? [
                        controller.appColor.value,
                        controller.appColor.value.withOpacity(0.8),
                      ]
                    : [
                        Colors.grey.shade300,
                        Colors.grey.shade400,
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: isUnlocked
                      ? controller.appColor.value.withOpacity(0.4)
                      : Colors.grey.withOpacity(0.3),
                  blurRadius: isCurrentLevel ? 12 : 8,
                  offset: const Offset(0, 4),
                  spreadRadius: isCurrentLevel ? 2 : 0,
                ),
              ],
              border: Border.all(
                color: isCurrentLevel ? Colors.white : Colors.transparent,
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                // Background pattern
                if (isUnlocked)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CustomPaint(
                        painter: GridPatternPainter(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                  ),

                // Content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isCurrentLevel)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'CURRENT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: controller.appColor.value,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      if (isCurrentLevel) const SizedBox(height: 8),
                      Text(
                        'Level',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color:
                              isUnlocked ? Colors.white : Colors.grey.shade600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color:
                              isUnlocked ? Colors.white : Colors.grey.shade700,
                          shadows: isUnlocked
                              ? [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (!isUnlocked)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.lock,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                        )
                      else if (isUnlocked && !isCurrentLevel)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            color: controller.appColor.value,
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                ),

                // Shimmer effect for current level
                if (isCurrentLevel)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: TweenAnimationBuilder(
                        tween: Tween<double>(begin: -1, end: 2),
                        duration: const Duration(seconds: 2),
                        // repeat: true,
                        builder: (context, double value, child) {
                          return CustomPaint(
                            painter: ShimmerPainter(progress: value),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLevelTap(
    BuildContext context,
    int index,
    bool isUnlocked,
    List<Offset> position,
    Offset comparizon1,
    Offset comparizon2,
    int highLevel,
    InAppPurchaseUtil inAppPurchaseUtil,
  ) {
    if (isUnlocked) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            List<int> puzzleConfig;

            if (index < Levels.levels.length) {
              puzzleConfig = Levels.levels[index];
            } else {
              puzzleConfig = Calculations.generateSolvablePuzzle();
              // generateSolvablePuzzle();
            }

            Log.d('Starting level ${index + 1} with config: $puzzleConfig');

            return TilesGround(
              level: index + 1,
              position: swapTiles(puzzleConfig, position),
              comparizon1: comparizon1,
              comparizon2: comparizon2,
              highLevel: highLevel,
            );
          },
        ),
      );
    } else {
      Get.dialog(
        GameOverAlert(
          title: 'Level Locked!',
          message:
              'Subscribe to unlock all levels or watch an ad to unlock the next level',
          negativeActionText: 'Watch Ad',
          positiveActionText: 'Subscribe',
          messageSize: 16,
          onNegativeAction: () {
            if (Get.isDialogOpen == true) {
    Future.delayed(const Duration(milliseconds: 300), () {
          Get.back();
        });
  }
            loadRewardedAd();
          },
          onPositiveAction: () {
            if (Get.isDialogOpen == true) {
   Future.delayed(const Duration(milliseconds: 300), () {
          Get.back();
        });
  }
            inAppPurchaseUtil.buyNonConsumable('8_puzzle_subscription');
          },
        ),
      );
    }
  }

  List<Offset> _generatePositions(Size size) {
    return List.generate(9, (index) {
      double height = size.height / 2 / 3 - 10;
      double width = size.width / 3 - 20;

      int row = index ~/ 3;
      int col = index % 3;

      double x = (size.width * 0.2) + width * col + (col * (width * 0.08));
      double y = size.height * 0.3 + (height + 10) * row;

      return Offset(x, y);
    });
  }

 List<Offset> swapTiles(List<int> puzzle, List<Offset> originalPositions) {
  List<Offset> newPositions = List.filled(9, Offset.zero);

  for (int i = 0; i < puzzle.length; i++) {
    int tileNumber = puzzle[i];
    newPositions[tileNumber] = originalPositions[i]; // ← Fixed!
  }

  return newPositions;
}

}

// /// FIXED: Generate solvable puzzle with correct winning configuration
// List<int> generateSolvablePuzzle() {
//   // Correct winning configuration: 0,1,2,3,4,5,6,7,8
//   List<int> puzzle = [0, 1, 2, 3, 4, 5, 6, 7, 8];
//   puzzle.shuffle();

//   // Count inversions (excluding the empty tile which is 8)
//   int inversions = 0;
//   for (int i = 0; i < puzzle.length; i++) {
//     if (puzzle[i] == 8) continue; // Skip empty tile

//     for (int j = i + 1; j < puzzle.length; j++) {
//       if (puzzle[j] == 8) continue; // Skip empty tile

//       // FIXED: Use AND (&&) instead of OR (||)
//       if (puzzle[j] < puzzle[i]) {
//         inversions++;
//       }
//     }
//   }

//   // For 3x3 puzzle, solvable if inversions are even
//   if (inversions % 2 == 0) {
//     // Ensure puzzle is not already solved
//     bool isSolved = true;
//     for (int i = 0; i < puzzle.length; i++) {
//       if (puzzle[i] != i) {
//         isSolved = false;
//         break;
//       }
//     }

//     if (isSolved) {
//       return generateSolvablePuzzle(); // Generate a new one
//     }

//     return puzzle;
//   } else {
//     return generateSolvablePuzzle();
//   }
// }

/// Custom painter for grid pattern background
class GridPatternPainter extends CustomPainter {
  final Color color;

  GridPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const spacing = 15.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for shimmer effect
class ShimmerPainter extends CustomPainter {
  final double progress;

  ShimmerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.transparent,
          Colors.white.withOpacity(0.1),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
        transform: GradientRotation(progress * 3.14159),
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
