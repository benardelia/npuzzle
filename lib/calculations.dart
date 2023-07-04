import 'dart:ui';

class Calculations {
// methode to swap tiles into solvable puzzle...
  static swapTiles(List<int> puzzle, List<Offset> copy) {
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

// methode to generate solvable puzzle by checkimg number of inversions
static List<int> generateSolvabePuzzle() {
    List<int> puzzle = [0, 1, 2, 3, 4, 5, 6, 7, 8];
    puzzle.shuffle();
    int inversions = 0;
    for (int i = 0; i < puzzle.length; i++) {
      for (int j = i + 1; j < puzzle.length; j++) {
        if (puzzle[j] < puzzle[i]) {
          if (puzzle[j] != 8 && puzzle[i] != 8) {
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
}
