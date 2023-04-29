import 'package:flutter/material.dart';

class TilesGround extends StatefulWidget {
  const TilesGround({super.key, required this.size});
  final Size size;

  @override
  State<TilesGround> createState() => _TilesGroundState();
}

class _TilesGroundState extends State<TilesGround> {
  // inition positions of all tiles including target
  static late List<Offset> position;
  List<Offset> positionCopy = List.generate(9, (index) => Offset(0, 0));
  // value of dragged tile, should be updated when ever the tile is draged
  // and seted to the current dragged tile
  int draggedTile = 0;
  Color favoriteColor = Color.fromARGB(255, 246, 95, 146);
  int moves = 0;
  late Offset comparizon1;
  late Offset comparizon2;

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  // }

  @override
  void initState() {
    super.initState();
    position = List.generate(
      9,
      (index) {
        Size size = widget.size;
        double height = size.height / 2 / 3 - 10;
        double width = size.width / 3 - 20;
        // generate different container's positions (offsets) according to their numbers
        // and ensure to fit in different screen sizes
        if (index < 3) {
          return Offset(size.width * 0.18,
              (size.height * 0.35) + height * index + (index * 2));
        }
        if (index >= 3 && index <= 5) {
          return Offset(size.width * 0.22 + width,
              (size.height * 0.35) + height * (index - 3) + ((index - 3) * 2));
        }
        if (index > 5) {
          return Offset(size.width * 0.26 + (width * 2),
              (size.height * 0.35) + height * (index - 6) + ((index - 6) * 2));
        }
        return const Offset(0, 9);
      },
    );

// this is like general rule to check if the moved item is adjacent to the empty item and its is not diagonal
    comparizon1 = position[8] - position[7];
    comparizon2 = position[8] - position[5];

//  swapping values to arrange them in assending order
    // var p1 = position[1], p2 = position[2], p3 = position[5];

    // position[2] = position[6];
    // position[1] = position[3];
    // position[5] = position[7];
    // position[6] = p2;
    // position[3] = p1;
    // position[7] = p3;

    // positionCopy = position;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                swapTiles([3, 4, 0, 6, 1, 8, 2, 5, 7], positionCopy);
                moves = 0;
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: favoriteColor),
            icon: const Icon(Icons.restart_alt),
            label: const Text('restart')),
        body: Stack(children: [
          Positioned(
              top: MediaQuery.of(context).size.width * 0.2,
              left: MediaQuery.of(context).size.width * 0.3,
              child: Text('Moves: $moves',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30))),
          tile(0),
          tile(1),
          tile(2),
          tile(3),
          tile(4),
          tile(5),
          tile(6),
          tile(7),
          target()
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

// methode to swap tiles into solvable puzzle...
  swapTiles(List<int> puzzle, List<Offset> copy) {
    var p1 = position[0];
    var p2 = position[1];
    var p3 = position[2];
    var p4 = position[3];
    var p5 = position[4];
    var p6 = position[5];
    var p7 = position[6];
    var p8 = position[7];
    var p9 = position[8];

    List<Offset> temp = [p1, p2, p3, p4, p5, p6, p7, p8, p9];

    for (int i = 0; i < puzzle.length; i++) {
      position[i] = temp[puzzle.indexOf(i)];
    }
    print(puzzle);
    print(temp);
    print(positionCopy);
    print(position);
    positionCopy = temp;
  }

// movable tile
  Widget tile(int x) {
    Size size = MediaQuery.of(context).size;
    double height = size.height / 2 / 3 - 10;
    double width = size.width / 3 - 20;
    return Positioned(
      left: position[x].dx - width / 2,
      top: position[x].dy - height / 2,
      child: Draggable(
          data: position[x], // should be used in drag target to update position
          onDragUpdate: (details) {
            setState(() {
              // update the draggedTile value when ever started dragged
              draggedTile = x;
              // up date the position of tile while it has been dragged
              //  position[x] = details.globalPosition;
            });
          },
          feedback: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: favoriteColor.withOpacity(0.8),
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
                borderRadius: BorderRadius.circular(5), color: favoriteColor),
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

  target() {
    Size size = MediaQuery.of(context).size;
    double height = size.height / 2 / 3 - 10;
    double width = size.width / 3 - 20;
    return Positioned(
      left: position[8].dx - width / 2,
      top: position[8].dy - height / 2,
      child: DragTarget(onAccept: (Offset data) {
        // data is the is adopted value or
        // object of dragable object, in this case the data of draggable object is
        // offset from the position list

        setState(() {
          var validMove = position[8] - position[draggedTile];
          if (comparizon1.dx.abs().ceil() == validMove.dx.abs().ceil() &&
                  comparizon1.dy.abs().ceil() == validMove.dy.abs().ceil() ||
              comparizon2.dx.abs().ceil() == validMove.dx.abs().ceil() &&
                  comparizon2.dy.abs().ceil() == validMove.dy.abs().ceil()) {
            position[draggedTile] = position[8];
            position[8] = data;
            moves++;
          }
        });
      }, builder: (context, candidateData, rejecteddata) {
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: const Color.fromARGB(255, 36, 45, 52)),
        );
      }),
    );
  }
}
