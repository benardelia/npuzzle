import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:npuzzle/audioplayer.dart';
import 'package:npuzzle/calculations.dart';
import 'package:npuzzle/firebase_analytics.dart';
import 'package:npuzzle/levels.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:npuzzle/state_management.dart/ads_controller.dart';
import 'package:npuzzle/state_management.dart/app_controller.dart';
import 'package:npuzzle/utils/logger.dart';
import 'package:npuzzle/widgets/game_over_alert.dart';

class TilesGround extends StatefulWidget {
  const TilesGround({
    super.key,
    required this.position,
    required this.comparizon1,
    required this.comparizon2,
    required this.level,
    required this.highLevel,
  });

  final List<Offset> position;
  final Offset comparizon1;
  final Offset comparizon2;
  final int level;
  final int highLevel;

  @override
  State<TilesGround> createState() => _TilesGroundState();
}

class _TilesGroundState extends State<TilesGround>
    with TickerProviderStateMixin {
  List<Offset> positionCopy = [];
  int draggedTile = 0;
  int moves = 0;
  bool isWin = false;
  late ConfettiController confettiController;
  final player = AudioPlayer();

  late AppController appController;
  late AdsController adsController;

  // Animation controllers
  late AnimationController _moveAnimationController;
  late AnimationController _tileScaleController;
  late Animation<double> _scaleAnimation;

  // Track last moved tile for animation
  int? lastMovedTile;

  @override
  void initState() {
    super.initState();
    Log.d(
        'Entering level ${widget.level} ✅  Config: ${widget.position} Comparizon1: ${widget.comparizon1} Comparizon2: ${widget.comparizon2}');
    appController = Get.find<AppController>();
    adsController = Get.find();

    confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    // Initialize animation controllers
    _moveAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _tileScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _tileScaleController, curve: Curves.easeInOut),
    );

    // Load ads
    adsController.loadBannerAd();
    adsController.showInterstitialAd();

    // Initialize position
    _resetPositions();

    // Start timer
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        appController.resetPeriod(discount: 1);
        appController.countDown();
      }
    });
  }

  void _resetPositions() {
    positionCopy.clear();
    for (var i in widget.position) {
      positionCopy.add(i);
    }
    moves = 0;
    lastMovedTile = null;
  }

  @override
  void dispose() {
    player.dispose();
    appController.timer?.cancel();
    confettiController.dispose();
    _moveAnimationController.dispose();
    _tileScaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (appController.restart.value == true) {
          _resetPositions();
          Log.i("Restarting level");
          appController.restart.value = false;
          // setState(() {});
        }

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                appController.appColor.value.withOpacity(0.1),
                Colors.white,
                appController.appColor.value.withOpacity(0.05),
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Header section with level and moves
                _buildHeader(),

                // Game tiles
                ...List.generate(8, (index) => _buildTile(index)),

                // Target (empty space)
                _buildTarget(context),

                // Confetti
                Positioned(
                  top: Get.height / 2,
                  left: Get.width / 2,
                  child: _buildConfetti(),
                ),

                // Bottom UI section
                _buildBottomUI(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeader() {
    return Positioned(
      top: 20,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Future.delayed(const Duration(milliseconds: 300), () {
                    Get.back();
                  });
                },
                color: appController.appColor.value,
              ),
            ),

            // Level indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    appController.appColor.value,
                    appController.appColor.value.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: appController.appColor.value.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.layers, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Level ${widget.level}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Moves counter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.touch_app,
                    color: appController.appColor.value,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: child,
                      );
                    },
                    child: Text(
                      '$moves',
                      key: ValueKey<int>(moves),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: appController.appColor.value,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(int index) {
    Size size = MediaQuery.of(context).size;
    double height = size.height / 2 / 3 - 10;
    double width = size.width / 3 - 20;

    final isLastMoved = lastMovedTile == index;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      left: positionCopy[index].dx - width / 2,
      top: positionCopy[index].dy - height / 2,
      child: Draggable<Offset>(
        data: positionCopy[index],
        onDragStarted: () {
          _tileScaleController.forward();
          HapticFeedback.lightImpact();
        },
        onDragEnd: (details) {
          _tileScaleController.reverse();
        },
        onDragUpdate: (details) {
          setState(() {
            draggedTile = index;
          });
        },
        feedback: Material(
          color: Colors.transparent,
          child: Transform.scale(
            scale: 1.1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    appController.appColor.value,
                    appController.appColor.value.withOpacity(0.7),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: appController.appColor.value.withOpacity(0.6),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              height: height,
              width: width,
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'sketch3d',
                    fontSize: 40,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: _buildTileContainer(index, height, width, isLastMoved: false),
        ),
        child:
            _buildTileContainer(index, height, width, isLastMoved: isLastMoved),
      ),
    );
  }

  Widget _buildTileContainer(int index, double height, double width,
      {required bool isLastMoved}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            appController.appColor.value,
            appController.appColor.value.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: isLastMoved
                ? appController.appColor.value.withOpacity(0.5)
                : appController.appColor.value.withOpacity(0.3),
            blurRadius: isLastMoved ? 12 : 8,
            offset: const Offset(0, 4),
            spreadRadius: isLastMoved ? 1 : 0,
          ),
        ],
        border: Border.all(
          color: isLastMoved ? Colors.white : Colors.transparent,
          width: 2,
        ),
      ),
      height: height,
      width: width,
      child: Stack(
        children: [
          // Grid pattern
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomPaint(
                painter: TilePatternPainter(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
          ),

          // Number
          Center(
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 50,
                fontFamily: 'sketch3d',
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTarget(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = size.height / 2 / 3 - 10;
    double width = size.width / 3 - 20;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      left: positionCopy[8].dx - width / 2,
      top: positionCopy[8].dy - height / 2,
      child: DragTarget<Offset>(
        onWillAccept: (data) {
          // Visual feedback for valid moves
          var validMove = positionCopy[8] - positionCopy[draggedTile];
          return (widget.comparizon1.dx.abs().ceil() ==
                      validMove.dx.abs().ceil() &&
                  widget.comparizon1.dy.abs().ceil() ==
                      validMove.dy.abs().ceil()) ||
              (widget.comparizon2.dx.abs().ceil() ==
                      validMove.dx.abs().ceil() &&
                  widget.comparizon2.dy.abs().ceil() ==
                      validMove.dy.abs().ceil());
        },
        onAccept: (Offset data) {
          _handleMove(data);
        },
        builder: (context, candidateData, rejectedData) {
          final bool isHovering = candidateData.isNotEmpty;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: height,
            width: width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isHovering
                  ? appController.appColor.value.withOpacity(0.3)
                  : Colors.grey.shade300,
              border: Border.all(
                color: isHovering
                    ? appController.appColor.value
                    : Colors.grey.shade400,
                width: 2,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
              boxShadow: [
                BoxShadow(
                  color: isHovering
                      ? appController.appColor.value.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                  blurRadius: isHovering ? 12 : 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: isHovering
                ? const Center(
                    child: Icon(
                      Icons.check_circle_outline,
                      color: Colors.white,
                      size: 40,
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }

  void _handleMove(Offset data) {
    var validMove = positionCopy[8] - positionCopy[draggedTile];

    // Check if the move is valid
    if ((widget.comparizon1.dx.abs().ceil() == validMove.dx.abs().ceil() &&
            widget.comparizon1.dy.abs().ceil() == validMove.dy.abs().ceil()) ||
        (widget.comparizon2.dx.abs().ceil() == validMove.dx.abs().ceil() &&
            widget.comparizon2.dy.abs().ceil() == validMove.dy.abs().ceil())) {
      setState(() {
        // Swap positions
        positionCopy[draggedTile] = positionCopy[8];
        positionCopy[8] = data;
        lastMovedTile = draggedTile;
        moves++;
      });

      // Haptic feedback
      HapticFeedback.mediumImpact();

      // Check for win condition
      _checkWinCondition();
    } else {
      // Invalid move feedback
      HapticFeedback.heavyImpact();
    }
  }

  void _checkWinCondition() {
    int passmark = 0;
    for (int x = 0; x < positionCopy.length; x++) {
      if (positionCopy[x].dx == Levels.winposition[x].dx &&
          positionCopy[x].dy == Levels.winposition[x].dy) {
        passmark++;
      }
    }

    if (passmark == 9) {
      _handleWin();
    }
  }

  void _handleWin() {
    // Play success sound
    Player(src: 'assets/congratulations.mp3').play();

    // Update level progress
    if (widget.level > widget.highLevel) {
      appController.appBox.put('val', widget.level);
    }

    // Start confetti
    setState(() {
      confettiController.play();
    });

    // Stop timer
    appController.timer?.cancel();

    // Log analytics
    FirebaseAnalyticsService.logLevelUp(level: widget.level + 1);

    // Show win dialog
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Get.dialog(
          GameOverAlert(
            title: '🎉 Congratulations!',
            message: 'Level ${widget.level} completed in $moves moves!',
            onNegativeAction: () async {
              // if (Get.isSnackbarOpen) {
              //   Get.closeAllSnackbars();
              // }
              if (Get.isDialogOpen == true) {
                Future.delayed(const Duration(milliseconds: 300), () {
                  Get.back();
                });
              }
              confettiController.stop();
              _resetPositions();
              appController.resetPeriod(discount: 1);
              appController.countDown();
              await player.release();
            },
            onPositiveAction: () async {
              // if (Get.isSnackbarOpen) {
              //   Get.closeAllSnackbars();
              // }
              if (Get.isDialogOpen == true) {
                Future.delayed(const Duration(milliseconds: 300), () {
                  Get.back();
                });
              }
              confettiController.stop();
              await player.release();
              _nextLevel(widget.level);
            },
            negativeActionText: 'Restart',
            positiveActionText: 'Next Level',
          ),
        );
      }
    });
  }

  Widget _buildConfetti() {
    return ConfettiWidget(
      confettiController: confettiController,
      shouldLoop: false,
      blastDirection: -3.14 / 2, // Up
      numberOfParticles: 50,
      maxBlastForce: 40,
      minBlastForce: 20,
      blastDirectionality: BlastDirectionality.explosive,
      colors: [
        appController.appColor.value,
        Colors.blue,
        Colors.green,
        Colors.yellow,
        Colors.orange,
        Colors.pink,
      ],
    );
  }

  Widget _buildBottomUI() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Timer display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.9),
                        Colors.white.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        color: appController.appColor.value,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Obx(() {
                        final remainingTime = appController.gamePeriod.value;
                        final isLowTime = remainingTime <= 10;

                        return AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isLowTime
                                ? Colors.red
                                : appController.appColor.value,
                          ),
                          child: Text(
                            '${remainingTime.toString().padLeft(2, '0')}s',
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                // Add time button
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      adsController.showRewardedAd();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appController.appColor.value,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    label: const Text(
                      'Add Time (+30s)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Banner ad
          if (adsController.bunnerAd?.value != null)
            Container(
              width: adsController.bunnerAd!.value.size.width.toDouble(),
              height: 70,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: AdWidget(
                ad: adsController.bunnerAd!.value,
              ),
            )
          else
            const SizedBox(height: 80),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void _nextLevel(int index) async {
    // if (Get.isSnackbarOpen == true) {
    //   Get.closeAllSnackbars();
    // }
    if (Get.isDialogOpen == true) {
      await Future.delayed(const Duration(milliseconds: 300));

      Get.back();
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          List<int> puzzleConfig;
          int newLevel = index + 1;

          if (newLevel < Levels.levels.length) {
            puzzleConfig = Levels.levels[newLevel];
          } else {
            puzzleConfig = Calculations.generateSolvablePuzzle();
            // generateSolvablePuzzle();
          }

          Log.d('Starting level ${index + 1} with config: $puzzleConfig');

          return TilesGround(
            level: newLevel,
            position: Calculations.swapTiles(
              puzzleConfig,
              Levels.winposition,
            ),
            comparizon1: widget.comparizon1,
            comparizon2: widget.comparizon2,
            highLevel: widget.highLevel,
          );
        },
      ),
    );

    // Future.delayed(const Duration(milliseconds: 100), () {
    //   Log.d('Going Next level $newLevel ✅');

    //   Get.to(TilesGround(
    //     level: newLevel,
    //     position: Calculations.swapTiles(
    //       puzzleConfig,
    //       Levels.winposition,
    //     ),
    //     comparizon1: widget.comparizon1,
    //     comparizon2: widget.comparizon2,
    //     highLevel: widget.highLevel,
    //   ));
    // });
  }
}

/// Custom painter for tile pattern
class TilePatternPainter extends CustomPainter {
  final Color color;

  TilePatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const spacing = 10.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

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
