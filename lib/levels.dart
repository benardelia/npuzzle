import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:npuzzle/colors.dart';
import 'package:npuzzle/ground.dart';
import 'package:npuzzle/main.dart';

class Levels extends StatefulWidget {
  const Levels({super.key, required this.changeMode, required this.darkMode});
  final Function changeMode;
  final bool darkMode;
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
  var level = Hive.box('level');
  late bool initialMode;
  @override
  void initState() {
    super.initState();
    initialMode = widget.darkMode;
    PlayGroung.mainColor = Color(level.get('color'));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(systemNavigationBarColor: PlayGroung.mainColor));
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

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          '8-Puzzle',
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        backgroundColor: PlayGroung.mainColor,
        scrolledUnderElevation: 5,
        elevation: 0,
      ),
      drawer: Drawer(
        width: size.width * 0.7,
        child: Column(
          children: [
            Image.asset('assets/8puzzle.png'),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.lock_open),
              label: const Text('Unlock level'),
            ),
            TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                          context: context, builder: (context) => PickColors())
                      .then((value) => setState(() {
                            SystemChrome.setSystemUIOverlayStyle(
                                SystemUiOverlayStyle(
                                    systemNavigationBarColor:
                                        PlayGroung.mainColor));
                          }));
                },
                icon: const Icon(Icons.color_lens),
                label: const Text('Change Color')),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.star_rate_rounded),
              label: const Text('Rate Us'),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.light_mode_outlined),
                Switch(
                    value: initialMode,
                    onChanged: (value) {
                      initialMode = !initialMode;
                      widget.changeMode(initialMode);
                    })
              ],
            )
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3),
            itemBuilder: (context, index) => InkWell(
                  onTap: () {
                    if (level.get('val') >= index) {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        if (index < 25) {
                          return TilesGround(
                            level: index + 1,
                            size: size,
                            position: swapTiles(Levels.levels[index], position),
                            comparizon1: comparizon1,
                            comparizon2: comparizon2,
                          );
                        } else {
                          return TilesGround(
                            level: index + 1,
                            size: size,
                            position:
                                swapTiles(generateSolvabePuzzle(), position),
                            comparizon1: comparizon1,
                            comparizon2: comparizon2,
                          );
                        }
                      }));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              'Your current level is ${level.get('val') + 1} please finish previous levels')));
                    }
                  },
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    color: PlayGroung.mainColor,
                    child: Center(
                      child: Text(
                        'Level\n${index + 1}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )),
      ),
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
