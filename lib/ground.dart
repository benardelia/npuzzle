import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:npuzzle/calculations.dart';
import 'package:npuzzle/levels.dart';
import 'package:npuzzle/main.dart';

class TilesGround extends StatefulWidget {
  const TilesGround(
      {super.key,
      required this.size,
      required this.position,
      required this.comparizon1,
      required this.comparizon2,
      required this.level});
  final Size size;
  final List<Offset> position;
  final Offset comparizon1;
  final Offset comparizon2;
  final int level;

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
  // Color favoriteColor = Color.fromARGB(255, 114, 124, 58);
  int moves = 0;
  bool isWin = false;
  ConfettiController confet = ConfettiController();

  @override
  void initState() {
    super.initState();
    positionCopy.clear();

    for (var i in widget.position) {
      positionCopy.add(i);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                nextLevel(widget.level - 1);
                moves = 0;
              });
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: PlayGroung.mainColor),
            icon: const Icon(Icons.restart_alt),
            label: const Text('restart')),
        body: Stack(children: [
          Positioned(
              top: MediaQuery.of(context).size.height * 0.1,
              left: MediaQuery.of(context).size.width * 0.1,
              child: Text('Level: ${widget.level}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25))),
          Positioned(
              top: MediaQuery.of(context).size.height * 0.1,
              left: MediaQuery.of(context).size.width * 0.5,
              child: Text('Moves: $moves',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25))),
          tile(0),
          tile(1),
          tile(2),
          tile(3),
          tile(4),
          tile(5),
          tile(6),
          tile(7),
          target(context),
          Positioned(
              top: widget.size.height / 2,
              left: widget.size.width / 2,
              child: applause())
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

  // applause or confet widget
  Widget applause() {
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
              color: PlayGroung.mainColor.withOpacity(0.8),
            ),
            height: height,
            width: width,
            child: Center(
              child: Text(
                '${x + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
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
                color: PlayGroung.mainColor),
            height: height,
            width: width,
            child: Center(
                child: Text(
              '${x + 1}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            )),
          )),
    );
  }

  var level = Hive.box('level');
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

            // define the winning state / check if the valid move result int winstate
            int passmark = 0;
            for (int x = 0; x < positionCopy.length; x++) {
              if (positionCopy[x].dx == Levels.winposition[x].dx &&
                  positionCopy[x].dy == Levels.winposition[x].dy) {
                passmark++;
              }
            }
            if (passmark == 9) {
              level.put('val', widget.level);
              setState(() {
                confet.play();
              });
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        content: SizedBox(
                          height: 150,
                          child: Center(
                            child: Text(
                              'You Won! \n  🤩😎',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                                color: PlayGroung.mainColor,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                setState(() {
                                  confet.stop();
                                });
                                nextLevel(widget.level - 1);
                              },
                              style: TextButton.styleFrom(
                                  backgroundColor: PlayGroung.mainColor,
                                  foregroundColor: Colors.white),
                              child: const Text(
                                'Restart',
                              )),
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                setState(() {
                                  confet.stop();
                                });
                                nextLevel(widget.level);
                              },
                              style: TextButton.styleFrom(
                                  backgroundColor: PlayGroung.mainColor,
                                  foregroundColor: Colors.white),
                              child: const Text('Next level'))
                        ],
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
              color: Color.fromARGB(255, 117, 125, 131)),
        );
      }),
    );
  }

  nextLevel(int index) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
      if (index < 24) {
        return TilesGround(
          level: index + 1,
          size: widget.size,
          position:
              Calculations.swapTiles(Levels.levels[index], Levels.winposition),
          comparizon1: widget.comparizon1,
          comparizon2: widget.comparizon2,
        );
      } else {
        return TilesGround(
          level: index + 1,
          size: widget.size,
          position: Calculations.swapTiles(
              Calculations.generateSolvabePuzzle(), Levels.winposition),
          comparizon1: widget.comparizon1,
          comparizon2: widget.comparizon2,
        );
      }
    }));
  }
}
