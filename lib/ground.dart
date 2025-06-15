import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:npuzzle/audioplayer.dart';
import 'package:npuzzle/calculations.dart';
import 'package:npuzzle/levels.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:npuzzle/state_management.dart/ads_controller.dart';
import 'package:npuzzle/state_management.dart/app_controller.dart';
import 'package:npuzzle/widgets/game_over_alert.dart';

class TilesGround extends StatefulWidget {
  const TilesGround(
      {super.key,
      // required this.size,
      required this.position,
      required this.comparizon1,
      required this.comparizon2,
      required this.level,
      required this.highLevel});
  // final Size size;
  final List<Offset> position;
  final Offset comparizon1;
  final Offset comparizon2;
  final int level;
  final int highLevel;

  @override
  State<TilesGround> createState() => _TilesGroundState();
}

class _TilesGroundState extends State<TilesGround> {
  // inition positions of all tiles including target
  // late List<Offset> position;
  List<Offset> positionCopy = [];
  // value of dragged tile, should be updated when ever the tile is draged
  // and seted to the current dragged tile
  int draggedTile = 0;
  int moves = 0;
  bool isWin = false;
  ConfettiController confet = ConfettiController();
  final player = AudioPlayer();

  late AppController appController;
  late AdsController adsController;

  @override
  void initState() {
    appController = Get.find<AppController>();
    adsController = Get.find();
    adsController.loadBannerAd();
    positionCopy.clear();
    for (var i in widget.position) {
      positionCopy.add(i);
    }
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      appController.countDown();
    });
  }

  @override
  void dispose() {
    player.dispose();
    appController.timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      Positioned(
          top: Get.height * 0.1,
          left: Get.width * 0.05,
          child: Text('Level: ${widget.level}',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
      Positioned(
          top: MediaQuery.of(context).size.height * 0.1,
          left: MediaQuery.of(context).size.width * 0.45,
          child: Text('Moves: $moves',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
      Positioned(
          top: MediaQuery.of(context).size.height * 0.07,
          left: MediaQuery.of(context).size.width * 0.8,
          child: IconButton(
              onPressed: () {
                // loadRewardedAd();
                adsController.showRewardedAd();
              },
              icon: Icon(
                Icons.lightbulb,
                color: moves > 50
                    ? const Color.fromARGB(255, 247, 172, 11)
                    : moves > 40
                        ? const Color.fromARGB(255, 33, 233, 15)
                        : moves > 30
                            ? const Color.fromARGB(255, 126, 240, 116)
                            : const Color.fromARGB(255, 238, 226, 201),
                size: MediaQuery.of(context).size.height * 0.07,
              ))),
      tile(0),
      tile(1),
      tile(2),
      tile(3),
      tile(4),
      tile(5),
      tile(6),
      tile(7),
      target(context),
      Positioned(top: Get.height / 2, left: Get.width / 2, child: applause()),
      Align(
        alignment: Alignment.bottomCenter,
        child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          Container(
            decoration: BoxDecoration(
                color: Colors.white.withAlpha(20),
                borderRadius: BorderRadius.circular(20)),
            child: Obx(() {
              return Padding(
                padding: const EdgeInsets.all(18.0),
                child: Text(
                    'Remaining Time: ${appController.gamePeriod.value.toString().padLeft(2, '0')}'),
              );
            }),
          ),
          const Divider(
            height: 10,
          ),
          // ad shown here
          // _ad != null
          adsController.bunnerAd?.value != null
              ? Obx(() {
                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width:
                          adsController.bunnerAd?.value.size.width.toDouble(),
                      height: 70,
                      alignment: Alignment.center,
                      child: AdWidget(
                        ad: adsController.bunnerAd!.value,
                      ),
                    ),
                  );
                })
              : const SizedBox(
                  height: 80,
                ),
          const SizedBox(
            height: 10,
          )
        ]),
      )
    ]));
  }

  // methode to generate solvable puzzle by checkimg number of inversions
  List<int> generateSolvabePuzzle() {
    List<int> puzzle = [0, 1, 4, 7, 2, 5, 8, 3, 6];
    puzzle.shuffle();
    int inversions = 0;
    for (int i = 0; i < puzzle.length; i++) {
      for (int j = i + 1; j < puzzle.length; j++) {
        if (puzzle[j] > puzzle[i]) {
          inversions++;
        }
      }
    }

    if (inversions % 2 == 0) {
      return puzzle;
    } else {
      return generateSolvabePuzzle();
    }
  }

// methode to play congraturations sound
  playSong() async {
    await player.play(AssetSource('assets/congratulations.mp3'));
  }

  // applause or confet widget
  applause() {
    return ConfettiWidget(
      confettiController: confet,
      shouldLoop: true,
      blastDirection: 30,
      numberOfParticles: 50,
      maxBlastForce: 40,
      blastDirectionality: BlastDirectionality.explosive,
    );
  }

// movable tile
  Widget tile(int x) {
    Size size = MediaQuery.of(context).size;
    double height = size.height / 2 / 3 - 10;
    double width = size.width / 3 - 20;
    return Positioned(
      left: positionCopy[x].dx - width / 2,
      top: positionCopy[x].dy - height / 2,
      child: Draggable(
          data: positionCopy[
              x], // should be used in drag target to update position
          onDragUpdate: (details) {
            setState(() {
              draggedTile = x;
            });
          },
          feedback: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: appController.appColor.value.withAlpha(200),
            ),
            height: height,
            width: width,
            child: Center(
              child: Text(
                '${x + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'sketch3d',
                  fontSize: 30,
                  color: Colors.black.withOpacity(0.8),
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: appController.appColor.value),
            height: height,
            width: width,
            child: Center(
                child: Text(
              '${x + 1}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 50,
                fontFamily: 'sketch3d',
              ),
            )),
          )),
    );
  }

  target(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = size.height / 2 / 3 - 10;
    double width = size.width / 3 - 20;
    return Positioned(
      left: positionCopy[8].dx - width / 2,
      top: positionCopy[8].dy - height / 2,
      child: DragTarget(onAccept: (Offset data) {
        // data is the is adopted value or
        // object of dragable object, in this case the data of draggable object is
        // offset from the position list

        setState(() {
          var validMove = positionCopy[8] - positionCopy[draggedTile];
          // check if the move is valid
          if (widget.comparizon1.dx.abs().ceil() == validMove.dx.abs().ceil() &&
                  widget.comparizon1.dy.abs().ceil() ==
                      validMove.dy.abs().ceil() ||
              widget.comparizon2.dx.abs().ceil() == validMove.dx.abs().ceil() &&
                  widget.comparizon2.dy.abs().ceil() ==
                      validMove.dy.abs().ceil()) {
            positionCopy[draggedTile] = positionCopy[8];
            positionCopy[8] = data;
            moves++;
            SystemSound.play(SystemSoundType.click);
            // define the winning state / check if the valid move result int winstate
            int passmark = 0;
            for (int x = 0; x < positionCopy.length; x++) {
              if (positionCopy[x].dx == Levels.winposition[x].dx &&
                  positionCopy[x].dy == Levels.winposition[x].dy) {
                passmark++;
              }
            }
            if (passmark == 9) {
              Player(src: 'assets/congratulations.mp3').play();

              if (widget.level > widget.highLevel) {
                appController.appBox.put('val', widget.level);
              }
              setState(() {
                confet.play();
              });
              appController.timer?.cancel();
              Get.dialog(GameOverAlert(
                title: 'You Won!',
                message: '😎🥳',
                onNegativeAction: () async {
                  Get.back();
                  confet.stop();
                  positionCopy.clear();
                  for (var i in widget.position) {
                    positionCopy.add(i);
                  }
                  appController.resetPeriod();
                  appController.countDown();
                  setState(() {});
                  await player.release();
                },
                onPositiveAction: () async {
                  Get.back();
                  setState(() {
                    confet.stop();
                  });
                  await player.release();
                  nextLevel(widget.level);
                },
                negativeActionText: 'Restart',
                positiveActionText: 'Next level',
              ));
            }
          }
        });
      }, builder: (context, candidateData, rejecteddata) {
        // empty container
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: const Color.fromARGB(255, 117, 125, 131)),
        );
      }),
    );
  }

  nextLevel(int index) async {
    Get.back();
    Get.to(index < 24
        ? TilesGround(
            level: index + 1,
            position: Calculations.swapTiles(
                Levels.levels[index], Levels.winposition),
            comparizon1: widget.comparizon1,
            comparizon2: widget.comparizon2,
            highLevel: widget.highLevel,
          )
        : TilesGround(
            level: index + 1,
            position: Calculations.swapTiles(
                Calculations.generateSolvabePuzzle(), Levels.winposition),
            comparizon1: widget.comparizon1,
            comparizon2: widget.comparizon2,
            highLevel: widget.highLevel,
          ));
  }
}
