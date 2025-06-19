import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:npuzzle/ads_helper.dart';
import 'package:npuzzle/ground.dart';
import 'package:npuzzle/inapp_purchase/inapp_purchase_util.dart';
import 'package:npuzzle/state_management.dart/app_controller.dart';
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

class _LevelsState extends State<Levels> {
  var controller = Get.find<AppController>();
  late bool initialMode;
  BannerAd? _ad;
  RewardedAd? _rewardedAd;
  int tries = 0;
  void loadRewardedAd() {
    // rewarded ad implemented here
    RewardedAd.load(
      adUnitId: AdHelper.rewardAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
              // Called when the ad showed the full screen content.
              onAdShowedFullScreenContent: (ad) {},
              // Called when an impression occurs on the ad.
              onAdImpression: (ad) {},
              // Called when the ad failed to show full screen content.
              onAdFailedToShowFullScreenContent: (ad, err) {
                // Dispose the ad here to free resources.
                ad.dispose();
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ad failed to load')));
              },
              // Called when the ad dismissed full screen content.
              onAdDismissedFullScreenContent: (ad) {
                // Dispose the ad here to free resources.
                ad.dispose();
              },
              // Called when a click is recorded for an ad.
              onAdClicked: (ad) {});
          debugPrint('$ad loaded.');
          // Keep a reference to the ad so you can show it later.
          _rewardedAd = ad;
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('RewardedAd failed to load: $error');
        },
      ),
    ).then((value) {
      if (_rewardedAd != null) {
        tries = 0;
        _rewardedAd!.show(
            onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
          // Reward the user for watching an ad.
          var currentLevel = controller.appBox.get('val');
          controller.appBox.put('val', currentLevel + 1);
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('One level Unlocked')));
        });
      } else {
        if (tries < 4) {
          loadRewardedAd();
        }
        tries++;
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _ad?.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: controller.appColor.value));
    // swapa(lvls);
    List<Offset> position = List.generate(
      9,
      (index) {
        // Size size = size;
        double height = size.height / 2 / 3 - 10;
        double width = size.width / 3 - 20;
        // generate different container's positions (offsets) according to their numbers
        // and ensure to fit in different screen sizes
        if (index < 3) {
          return Offset(
              (size.width * 0.2) + width * index + (index * (width * 0.08)),
              size.height * 0.3);
        }
        if (index >= 3 && index <= 5) {
          return Offset(
              (size.width * 0.2) +
                  width * (index - 3) +
                  ((index - 3) * (width * 0.08)),
              size.height * 0.3 + height + 10);
        }
        if (index > 5) {
          return Offset(
              (size.width * 0.2) +
                  width * (index - 6) +
                  ((index - 6) * (width * 0.08)),
              size.height * 0.3 + ((height + 10) * 2));
        }
        return const Offset(0, 9);
      },
    );

// this is like general rule to check if the moved item is adjacent to the empty item and its is not diagonal
    Offset comparizon1 = position[8] - position[7];
    Offset comparizon2 = position[8] - position[5];
    Levels.winposition = position;

    final inAppPurchaseUtil = Get.find<InAppPurchaseUtil>();

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton(
        backgroundColor: controller.appColor.value.withBlue(150),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return const Instruction();
              });
        },
        child: const Icon(Icons.info_outline),
      ),
      appBar: AppBar(
        title: const Text(
          '8-Puzzle',
          style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.normal,
              fontFamily: 'sketch3d'),
        ),
        backgroundColor: controller.appColor.value,
        scrolledUnderElevation: 5,
        elevation: 0,
      ),
      drawer: const SideNavigator(),
      body: Obx(() {
        //  just for Obx to work
        controller.currentLevel.value;
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3),
              itemBuilder: (context, index) => InkWell(
                    onTap: () {
                      if (controller.appBox.get('val') >= index) {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          if (index < 25) {
                            return TilesGround(
                              level: index + 1,
                              // size: size,
                              position:
                                  swapTiles(Levels.levels[index], position),
                              comparizon1: comparizon1,
                              comparizon2: comparizon2,
                              highLevel: controller.appBox.get('val'),
                            );
                          } else {
                            return TilesGround(
                              level: index + 1,
                              // size: size,
                              position:
                                  swapTiles(generateSolvabePuzzle(), position),
                              comparizon1: comparizon1,
                              comparizon2: comparizon2,
                              highLevel: controller.appBox.get('val'),
                            );
                          }
                        }));
                      } else {
                        // Get.snackbar(
                        //   'Level Locked',
                        //   'Your current level is ${controller.appBox.get('val') + 1} please finish previous levels',
                        // );

                        Get.dialog(GameOverAlert(
                          title: 'Level Locked!',
                          message: 'Subscribe to unlock all levels',
                          negativeActionText: 'Cancel',
                          positiveActionText: 'Subscribe',
                          messageSize: 18,
                          onNegativeAction: () {
                            Get.back();
                          },
                          onPositiveAction: () {
                            Get.back();
                            inAppPurchaseUtil
                                .buyNonConsumable('8_puzzle_subscription');
                          },
                        ));
                      }
                    },
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      color: controller.appColor.value,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 4,
                          children: [
                            const Text(
                              'Level',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${index + 1}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            controller.appBox.get('val') < index
                                ? const Icon(Icons.lock)
                                : const SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ),
                  )),
        );
      }),
    );
  }

  // methode to swap tiles into solvable puzzle...
  swapTiles(List<int> puzzle, List<Offset> copy) {
    var p1 = copy[0];
    var p2 = copy[1];
    var p3 = copy[2];
    var p4 = copy[3];
    var p5 = copy[4];
    var p6 = copy[5];
    var p7 = copy[6];
    var p8 = copy[7];
    var p9 = copy[8];
    List<Offset> position = [p1, p2, p3, p4, p5, p6, p7, p8, p9];
    List<Offset> temp = [p1, p2, p3, p4, p5, p6, p7, p8, p9];

    for (int i = 0; i < puzzle.length; i++) {
      position[i] = temp[puzzle.indexOf(i)];
    }
    return position;
  }
}

// methode to generate solvable puzzle by checkimg number of inversions
List<int> generateSolvabePuzzle() {
  List<int> puzzle = [0, 1, 4, 7, 2, 5, 8, 3, 6];
  puzzle.shuffle();
  int inversions = 0;
  for (int i = 0; i < puzzle.length; i++) {
    for (int j = i + 1; j < puzzle.length; j++) {
      if (puzzle[j] < puzzle[i]) {
        if (puzzle[j] != 8 || puzzle[i] != 8) {
          inversions++;
        }
      }
    }
  }

  if (inversions % 2 == 0) {
    return puzzle;
  } else {
    return generateSolvabePuzzle();
  }
}
